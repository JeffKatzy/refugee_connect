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
  after_create :set_user

  phony_normalize :incoming_number

  def twilio_response
    Rails.logger.info("#{self.id} now responding to the word #{body} at #{Time.current}")
    self.reload
    if body.downcase == "go"
      Rails.logger.info("#{self.id} now attempting session at #{Time.current}")
      attempt_session
    elsif body.downcase == "sorry"
      TextToUser.deliver(user, "Thanks for letting us know, we'll find someone else.")
      appointment = user.appointments.next_appointment
      if appointment.present? 
        notify_admin_of_the_cancellation_of(appointment)
        appointment.status = "cancelled by #{user.id}"
        appointment.save
      end
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
    self.appointment = last_text.appointment
    self.save
    if appointment.scheduled_for.hour == Time.current.hour
      puts "about to call start_call"
      Rails.logger.info("Text from User #{self.id} with user #{user.id} with appointment #{appointment.id}")
      appointment.start_call
    else
      appointment = user.appointments.next_appointment
      begin
        body = appointment[:scheduled_for].in_time_zone.strftime("No sessions for this hour. Your next session is at %I:%M%p on %A.")
        TextToUser.deliver(self.user, body)
      rescue NoMethodError
        Rails.logger.debug("The next session doesn't exist for this user. ID: #{user.id}")
      end
    end
  end

  def set_new_page
    puts "in set_new_page"
    appointment = user.appointments.needs_text.most_recent.first
    appointment.finish_page = body.to_i  
    appointment.save
    puts "updating appointment #{appointment.id} with page number #{body.to_i} and it saved as #{appointment.finish_page}"
    # user.set_current_lesson(appointment.finish_page)
    TextToUser.deliver(user, "Thanks, we just saved the page number.")
  end

  def send_error_text
    body = "We could not understand your text. Please type 'go' to call the student, 'call off' to 
    call off the call, or enter the page number you last left off at."
    TextToUser.deliver(user, body)
    appointment = user.appointments.this_hour
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
