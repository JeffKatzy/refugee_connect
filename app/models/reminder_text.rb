# == Schema Information
#
# Table name: reminder_texts
#
#  id             :integer          not null, primary key
#  appointment_id :integer
#  time           :datetime
#  user_id        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  category       :string(255)
#

class ReminderText < ActiveRecord::Base
  attr_accessible :appointment_id, :category, :time, :user_id
  belongs_to :appointment
  belongs_to :user

  SPECIFIC_OPENING_REMINDER = 'specific_opening_reminder'
  BEGIN_SESSION = "begin_session"
  SET_PAGE_NUMBER = "set_page_number"
  PM_REMINDER = "pm_reminder"
  JUST_BEFORE = "just_before_reminder"
  REQUEST_CONFIRMATION = 'request_confirmation'

  def self.begin_session
    appointments_batch = Appointment.batch_for_begin_text
    ReminderText.send_reminder_text(appointments_batch, BEGIN_SESSION) 
  end

  def self.confirm_specific_openings
    specific_openings_batch = SpecificOpening.available.today
    ReminderText.ask_if_available(specific_openings_batch, REQUEST_CONFIRMATION)
  end

  # def self.set_page_number #remind delinquents to enter page number
  #   appointments_batch = Appointment.needs_text 
  #   ReminderText.send_reminder_text(appointments_batch, SET_PAGE_NUMBER) 
  # end

  private

  def self.ask_if_available(specific_openings_batch, category)
    specific_openings_batch.each do |specific_opening|
      if specific_opening.user.is_tutor?
        body = ReminderText.body(specific_opening, category)
      else 
        category = SPECIFIC_OPENING_REMINDER
        body = ReminderText.body(specific_opening, category)
      end
      tutor_text = TextToUser.deliver(specific_opening.user, body)
      specific_opening.update_attributes(status: 'requested_confirmation')
      reminder_text = ReminderText.create(time: Time.now, user_id: specific_opening.user.id, category: category) 
    end
  end

  def self.send_reminder_text(appointments_batch, category)
    appointments_batch.each do |apt|
      unless apt.reminder_texts.where(category: "#{category}").any?
        body = ReminderText.body(apt, category)
        tutor_text = TextToUser.deliver(apt.tutor, body) 
        tutor_text.appointment = apt
        tutor_text.save
        reminder_text = ReminderText.create(time: Time.now, appointment_id: apt.id, user_id: apt.tutor.id, category: category) 
        begin
          tutee_text = TextToUser.deliver(apt.tutee, body) 
          tutee_text.appointment = apt
          tutee_text.save
        rescue
          return puts "could not send to tutee"
          tutee_text.received = "could_not_send"
          tutee_text.save
        end
      end
    end
  end

  def self.body(object, category)
    time = object.scheduled_for_to_text('tutor')
    upcoming_session = "Tutoring Reminder: upcoming session at"
    admin_session = "Please email jek2141@columbia.edu to reschedule or cancel the session."
    if category == SPECIFIC_OPENING_REMINDER
      "You have a session today at #{time}.  If you cannot attend the class, do not answer the phone when you receive the call."
    elsif category == BEGIN_SESSION
      "Your class at #{time} is now ready to start.  Reply to this text with the word 'go' to start the call or 'c' to cancel."
    elsif category == REQUEST_CONFIRMATION
      "Can you still teach at #{time}?  Text back 'Y' to confirm or text 'N' to cancel."
    elsif category == SET_PAGE_NUMBER
      "Reminder: Please text the page number that you last left off at."
    elsif category == PM_REMINDER
      upcoming_session + " #{time} beginning on page #{object.start_page}.  " + admin_session
    elsif category == JUST_BEFORE
      upcoming_session + " #{time} beginning on page #{object.start_page}.  " + admin_session
    else
      raise 'must pass in valid category'
    end
  end
end
