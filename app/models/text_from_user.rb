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
#

require 'builder'
class TextFromUser < ActiveRecord::Base
  belongs_to :user
  attr_accessible :body, :time, :user_id, :incoming_number
  after_create :respond

  phony_normalize :incoming_number

  def respond
    if body.downcase == "go"
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
    self.reload
    @user = User.find(self.user_id)
    if @user.appointments.this_hour.present? 
      appointment = @user.appointments.this_hour.first
      appointment.start_call
    else
      appointment = @user.appointments.next_appointment
      begin
        body = appointment[:scheduled_for].in_time_zone.strftime("No sessions for this hour. Your next session is at %I:%M%p on %A.")
        TextToUser.deliver(@user, body)
      rescue NoMethodError
        Rails.logger.debug("The next session doesn't exist for this user. ID: #{@user.id}")
      end
    end
  end

  def set_new_page
    appointment = user.appointments.needs_text.most_recent.first
    appointment.finish_page = body.to_i  
    appointment.save
    TextToUser.deliver(user, "Thanks, we just saved the page number.")
  end

  def send_error_text
    body = "We could not understand your text. Please type 'go' to call the student, 'call off' to 
    call off the call, or enter the page number you last left off at."
    TextToUser.deliver(user, body)
    appointment = user.appointments.this_hour
  end


  def find_user_from_number
    User.find_by_cell_number(incoming_number)
  end

  def notify_admin_of_the_cancellation_of(appointment)
    first = "#{appointment.tutor.name} cancelled the session with #{appointment.tutee.name} at "
    second = appointment[:scheduled_for].in_time_zone.strftime("%I:%M%p on %A")
    admin = User.first
    body = first + second
    TextToUser.deliver admin, body
  end
end
