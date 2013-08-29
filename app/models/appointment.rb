# == Schema Information
#
# Table name: appointments
#
#  id            :integer          not null, primary key
#  status        :string(255)
#  start_page    :integer
#  finish_page   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  began_at      :datetime
#  ended_at      :datetime
#  scheduled_for :datetime
#  tutor_id      :integer
#  tutee_id      :integer
#

class Appointment < ActiveRecord::Base
  attr_accessible :finish_page, :start_page, :status, :scheduled_for, :user_id, :began_at, :ended_at
  
  scope :after, ->(time) { where("scheduled_for > ?", time) }
  scope :before, ->(time) { where("scheduled_for < ?", time) }
  scope :this_week, after(Time.now.utc.beginning_of_week).before(Time.now.utc.end_of_week)
  scope :most_recent, :limit => 1, :order => 'began_at DESC'
  
  #perhaps make incomplete the default scope
  scope :this_hour, after(Time.now.beginning_of_hour).before(Time.now.end_of_hour)  #for some reason this was not working
  scope :tomorrow, after(Time.now.end_of_day).before(Time.now.end_of_day + 24.hours)
  scope :incomplete, where(status: 'incomplete')
  scope :complete, where(status: 'complete')
  scope :needs_text, complete.where("finish_page IS NULL")
  scope :next_appointments, incomplete.after(Time.now.utc).order(:scheduled_for)
  scope :fully_assigned, where("tutee_id IS NOT NULL AND tutor_id IS NOT NULL")
  scope :in_half_a_day, where("begin_time between (?) and (?)", Time.now.utc + 16.hours, (Time.now.utc + 16.7.hours))
  scope :in_forty_minutes, where("begin_time between (?) and (?)", Time.now.utc, (Time.now.utc + 40.minutes))

  scope :batch_for_this_hour, fully_assigned.this_hour
  scope :batch_for_pm_reminder_text, fully_assigned.in_half_a_day
  scope :batch_for_am_reminder_text, fully_assigned.in_half_a_day.tomorrow
  scope :batch_for_just_before_reminder_text, fully_assigned.in_forty_minutes
  #check to see if this still works
  belongs_to :user
  belongs_to :tutor, class_name: 'User', foreign_key: :tutor_id
  belongs_to :tutee, class_name: 'User', foreign_key: :tutee_id
  has_many :call_to_users
  has_many :reminder_texts

  #only allow one appointment per hour per user

  def find_start_page
    most_recent_appointment = self.tutee.appointments.most_recent
    self.start_page = most_recent_appointment.start_page
    self.save
  end

  def self.batch(user, match_hash)
    match_hash.each do |match|
      matching_user_id = match.split(".").first.to_i
      matching_time = match.split(".").second.to_datetime
      appointment = Appointment.create(scheduled_for: matching_time)
      appointment.assign_user_role(matching_user_id)
      appointment.assign_user_role(user.id)
      appointment.start_page = appointment.tutee.last_page_completed if appointment.tutee.last_page_completed.present?
      appointment.status = 'incomplete'
      appointment.save
      
    end
  end

  def assign_user_role(user_id)
    user = User.find(user_id)
    if user.is_tutor?
      self.tutor = user
    else 
      self.tutee = user
    end
    self.save
  end

  def self.next_appointment #next_appointment includes the current_appointment
    next_appointments.first
  end

  def self.current #subset of next_appointment
    next_appointment if next_appointment.present? && next_appointment.scheduled_for.hour == Time.now.hour
  end

  def self.needs_page_number
    where('status == complete AND finish_page == nil')
  end

  def start_call
  	self.call_to_users.build(tutor_id: tutor.id, tutee_id: tutee.id)
  	self.call_to_users.last.start_call
  end

  def set_status
    self.status = 'complete' if began_at.present? && ended_at.present?
    self.save
  end
end
