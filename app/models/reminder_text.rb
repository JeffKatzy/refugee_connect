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

  def self.begin_session
    appointments_batch = Appointment.batch_for_begin_text
    appointments_batch.each do |apt|
      unless apt.texts.any?
        text = BeginSessionText.create(unit_of_work_id: apt.id, user_id: apt.tutor.id)
        tutor_text = TextToUser.deliver(apt.tutor, text.body) 
        begin
          text = BeginSessionText.create(unit_of_work_id: apt.id, user_id: apt.tutee.id)
          tutee_text = TextToUser.deliver(apt.tutee, text.body) 
        rescue
          puts "could not send to tutee"
        end
      end
    end
  end

  def self.missing_apts
    sos_no_apts = SpecificOpening.confirmed
      .where('appointment_id IS NULL')
      .after(Time.current.utc.beginning_of_hour).before(Time.current.utc)
    sos_no_apts.map do |specific_opening|
      text = NoAppointmentMatchedText.create(unit_of_work_id: specific_opening.id)
      tutor_text = TextToUser.deliver(text.user, text.body)
      specific_opening.update_attributes(status: 'unmatched')
      specific_opening
    end
  end

  def self.confirm_specific_openings
    specific_openings_batch = SpecificOpening.available.where('scheduled_for >=?', Time.current.utc.beginning_of_day).
      where('scheduled_for <=?', Time.current.utc.end_of_day)
    specific_openings_batch.each do |specific_opening|
      next if specific_opening.user.nil?
      text = Text::SpecificOpeningReminderText.create(unit_of_work_id: specific_opening.id)
      tutor_text = TextToUser.deliver(text.user, text.body)
      specific_opening.update_attributes(status: 'requested_confirmation')
    end
  end
end
