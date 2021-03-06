# == Schema Information
#
# Table name: text_from_users
#
#  id              :integer          not null, primary key
#  body            :text
#  time            :datetime
#  user_id         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  incoming_number :string(255)
#  city            :string(255)
#  state           :string(255)
#  zip             :string(255)
#  country         :string(255)
#  appointment_id  :integer
#

require 'builder'
class TextFromUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :appointment
  attr_accessible :body, :time, :user_id, :incoming_number
  before_save :format_phone_number
  after_create :set_user
  attr_accessor :appointment

  def twilio_response
    Rails.logger.info("#{self.id} now responding to the word #{body} at #{Time.current.utc}")
    self.reload
    body = self.body.downcase.strip
    if body == "go"
      Rails.logger.info("#{self.id} now attempting session at #{Time.current.utc}")
      attempt_session
    elsif body == "y"
      opening = find_specific_opening
      if opening
        opening.confirm 
        text = ConfirmationYesResponseText.create(unit_of_work_id: opening.id)
        TextToUser.deliver(text.user, text.body)
      end
    elsif body == 'n'
      opening = find_specific_opening
      opening.cancel
    elsif body.to_i != 0
      if user.appointments.needs_text.present?
        puts "about to call set_new_page"
        set_new_page 
      else
        TextToUser.deliver(user, "We can only save page numbers for sessions where you did not tell us page number.")
      end
    else
      send_error_text
    end
  end 

  #the only thing untested is attempt session.
  def attempt_session
    puts "in attempt_session"
    self.reload.user
    assign_appointment
    if self.user.appointments.today.include?(self.appointment) && (self.appointment.scheduled_for.utc.hour == Time.current.utc.hour)
      puts "about to call start_call"
      Rails.logger.info("Text_from_user number #{self.id} from user #{user.id} with appointment #{appointment.id}")
      self.appointment.start_call
    else
      begin
        Rails.logger.info("In no sessions this hour")
        body = "No sessions for this hour. Check your profile page to see your next opening"
        TextToUser.deliver(self.user, body)
      rescue NoMethodError #why do you need to do this?
        Rails.logger.debug("The next session doesn't exist for this user. ID: #{user.id}")
      end
    end
  end

  def assign_appointment
    last_text = BeginSessionText.where(user_id: self.user).last
    if last_text
      self.appointment = last_text.appointment
      save
    end
  end

  def find_specific_opening
    specific_opening = user.specific_openings.where('scheduled_for >=?', Time.current.utc.beginning_of_day).
      where('scheduled_for <=?', Time.current.utc.end_of_day).first
    if specific_opening
      puts "found specific opening #{specific_opening.id}"
      specific_opening
    else
      puts "did not find specific opening"
      send_could_not_find_opening_text
      nil
    end
  end


  def set_new_page
    puts "in set_new_page"
    appointment = user.appointments.needs_text.most_recent.first
    appointment.finish_page = body.to_i  
    appointment.save(validate: false)
    puts "updating appointment #{appointment.id} with page number #{body.to_i} and it saved as #{appointment.finish_page}"
    # user.set_current_lesson(appointment.finish_page)
    TextToUser.deliver(user, "Thanks, we just saved the page number.")
  end

  def send_error_text
    body = "We could not understand your text. Please type 'go' to call the student, 'y' to 
    confirm your appointmet or 'n' to cancel."
    TextToUser.deliver(user, body)
  end

  def send_could_not_find_opening_text
    body = "We could not find a specific opening that you have scheduled for for this time."
    TextToUser.deliver(user, body)
  end

  def set_user
    find_user_from_number
    if (@user.present? && !@user.incomplete_mobile_signup?)
      twilio_response
    else
      register_user
    end
  end

  def find_user_from_number
    @user = User.find_by_cell_number(incoming_number)
    self.user = @user
    self.save
    logger.debug "setting user to #{user}"
  end

  def format_phone_number
    puts "in format phone number"
    self.incoming_number = self.incoming_number.phony_formatted(format: :international, spaces: "")
    puts "incoming number is #{incoming_number}"
  end

  def register_user
    @user = User.find_by_cell_number(self.incoming_number)
    if @user.present?
      @signup = TextSignup.find_by_user_id(self.user.id)
    else
      @signup = TextSignup.create
    end
    @signup.navigate_signup(self)
  end

  def notify_admin_of_the_cancellation_of(appointment)
    first = "#{appointment.tutor.name} cancelled the session with #{appointment.tutee.name} at "
    second = appointment[:scheduled_for].in_time_zone.strftime("%I:%M%p on %A")
    admin = User.first
    body = first + second
    TextToUser.deliver admin, body
  end
end
