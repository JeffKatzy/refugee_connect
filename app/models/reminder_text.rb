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

  scope :begin_sessions, where(category: 'begin_session')
  scope :set_page_numbers, where(category: 'set_page_number')
  scope :pm_reminders, where(category: 'pm_reminder')
  scope :just_befores, where(category: 'just_before')

  belongs_to :appointment
  belongs_to :user

  
  def self.begin_session
    appointments_batch = Appointment.batch_for_this_hour
    appointments_batch.each do |appointment|
    	unless appointment.reminder_texts.where(category: 'begin_session').present?
    		reminder = ReminderText.create(time: Time.now, appointment_id: appointment.id, user_id: appointment.tutor.id)
      	first_part = appointment[:scheduled_for].in_time_zone("America/New_York").strftime("Your class at %I:%M%p ")
      	second_part = "on page #{appointment.start_page} is now ready to start.  Reply to this text with the word 'go' to start the call or 'sorry' to cancel." 
      	body_of_text = first_part + second_part 
      	TextToUser.deliver(appointment.tutor, body_of_text) 
      end
    end
  end

  def self.set_page_number #remind delinquents to enter page number
    appointments_batch = Appointment.needs_text
    unless appointment.reminder_texts.where(category: 'set_page_number').present?
	    body = "Please text the page number that you last left off at."
	    appointments_batch.each do |appointment|
	    	reminder_text = ReminderText.create(time: Time.now, appointment_id: appointment.id, user_id: appointment.tutor.id )
	      TextToUser.deliver(appointment.tutor, body) 
	    end
	  end
  end

  def self.deliver_pm_reminder_text
  	unless appointment.reminder_texts.where(category: 'pm_reminder').present?
    	texts_batch = TutoringSession.batch_for_pm_reminder_text
    	send_reminder_text(appointments_batch)
    	reminder_text = ReminderText.create(time: Time.now, appointment_id: appointment.id, user_id: appointment.tutor.id) 
    end
  end

  def self.deliver_just_before_reminder_text
  	unless appointment.reminder_texts.where(category: 'just_before').present?
    	texts_batch = TutoringSession.batch_for_just_before_reminder_text 
    	send_reminder_text(texts_batch)
    	reminder_text = ReminderText.create(time: Time.now, appointment_id: appointment.id, user_id: appointment.tutor.id) 
    end
  end

  private

  def self.send_reminder_text(appointments_batch)
    appointments_batch.each do |text|
      #text is tutoring session
      first_part = text[:begin_time].in_time_zone("America/New_York").strftime("Tutoring Reminder: upcoming session at %I:%M%p beginning")
      second_part = "on page #{page_number}.  Please email jek2141@columbia.edu to reschedule or cancel the session." 
      body_of_text = first_part + second_part
      TextToUser.deliver(appointment.tutor, body) 
    end
  end
  
end