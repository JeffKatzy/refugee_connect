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
  # scope :begin_sessions, where(category: 'begin_session')
  # scope :set_page_numbers, where(category: 'set_page_number')
  # scope :pm_reminders, where(category: 'pm_reminder')
  # scope :just_befores, where(category: 'just_before')

  belongs_to :appointment
  belongs_to :user

  BEGIN_SESSION = "begin_session"
  SET_PAGE_NUMBER = "set_page_number"
  PM_REMINDER = "pm_reminder"
  JUST_BEFORE = "just_before_reminder"
  
  #perhaps use state machine here

  def self.begin_session
    appointments_batch = Appointment.batch_for_this_hour  	
    ReminderText.send_reminder_text(appointments_batch, BEGIN_SESSION) 
  end

  def self.set_page_number #remind delinquents to enter page number
    appointments_batch = Appointment.needs_text 
    ReminderText.send_reminder_text(appointments_batch, SET_PAGE_NUMBER) 
  end

  def self.apts_in_one_day
  	appointments_batch = Appointment.batch_for_one_day_from_now
  	ReminderText.send_reminder_text(appointments_batch, PM_REMINDER)
  end

  def self.just_before_apts
  	appointments_batch = Appointment.batch_for_just_before
  	ReminderText.send_reminder_text(appointments_batch, JUST_BEFORE)	
  end

  def self.send_reminder_text(appointments_batch, category)
    appointments_batch.each do |apt|
      unless apt.reminder_texts.where(category: "#{category}").any?
        body = ReminderText.body(apt, category)
        TextToUser.deliver(apt.tutor, body) 
        reminder_text = ReminderText.create(time: Time.now, appointment_id: apt.id, user_id: apt.tutor.id) 
      end
    end
  end

  def self.body(appointment, category)
    time = appointment.scheduled_for_to_text('tutor')
    upcoming_session = "Tutoring Reminder: upcoming session at"
    admin_session = "Please email jek2141@columbia.edu to reschedule or cancel the session." 
    if category == BEGIN_SESSION
      "Your class at #{time} is now ready to start.  Reply to this text with the word 'go' to start the call or 'sorry' to cancel."
    elsif category == SET_PAGE_NUMBER
      "Please text the page number that you last left off at."
    elsif category == PM_REMINDER
      upcoming_session + " #{time} beginning on page #{appointment.start_page}.  " + admin_session
    elsif category == JUST_BEFORE
      upcoming_session + " #{time} beginning on page #{appointment.start_page}.  " + admin_session
    else
      raise 'must pass in valid category'
    end
  end
end
