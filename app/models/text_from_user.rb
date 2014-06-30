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
        TextToUser.deliver(user, "Great you are all set.  You will receive a text from us at the scheduled time")
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
    self.user.reload
    last_text = user.text_to_users.last
    if last_text
      appointment = self.appointment = last_text.appointment
      self.save
    end
    if appointment && appointment.scheduled_for.hour == Time.current.hour
      puts "about to call start_call"
      Rails.logger.info("Text from User #{self.id} with user #{user.id} with appointment #{appointment.id}")
      appointment.start_call
    else
      appointment = user.appointments.next_appointment
      begin
        body = appointment[:scheduled_for].in_time_zone.
          strftime("No sessions for this hour. Your next session is at %I:%M%p on %A.")
        TextToUser.deliver(self.user, body)
      rescue NoMethodError
        Rails.logger.debug("The next session doesn't exist for this user. ID: #{user.id}")
      end
    end
  end

  def find_specific_opening
    specific_opening = user.specific_openings.today.first
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
