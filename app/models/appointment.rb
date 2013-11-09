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
  attr_accessible :finish_page, :start_page, :status, :scheduled_for, :tutor_id, :began_at, :ended_at, :tutee_id, :availability_manager_id

  default_scope where("tutee_id IS NOT NULL AND tutor_id IS NOT NULL")
  scope :after, ->(time) { where("scheduled_for >= ?", time) }
  scope :before, ->(time) { where("scheduled_for <= ?", time) }
  scope :this_week, after(Time.current.utc.beginning_of_week).before(Time.current.utc.end_of_week)
  scope :recent_inclusive, :limit => 1, :order => 'began_at DESC'
  
  #perhaps make incomplete the default scope
  # scope :this_hour, after(Time.current.beginning_of_hour).before(Time.current.end_of_hour)  #for some reason this was not working
  scope :tomorrow, after(Time.current.end_of_day).before(Time.current.end_of_day + 24.hours)
  scope :incomplete, where(status: 'incomplete')
  scope :complete, where(status: 'complete')
  scope :needs_text, complete.where("finish_page IS NULL")
  scope :next_appointments, incomplete.after(Time.current.utc).order(:scheduled_for)
  scope :in_half_a_day, where("scheduled_for between (?) and (?)", Time.current.utc + 16.hours, (Time.current.utc + 16.7.hours))
  scope :in_forty_minutes, where("scheduled_for between (?) and (?)", Time.current.utc, (Time.current.utc + 40.minutes))
  scope :fully_assigned, where("tutee_id IS NOT NULL AND tutor_id IS NOT NULL")

  scope :most_recent, complete.recent_inclusive

  scope :this_hour, where("scheduled_for between (?) and (?)", Time.current.beginning_of_hour, Time.current.end_of_hour)
  scope :batch_for_this_hour, this_hour
  
  #check to see if this still works
  belongs_to :user
  belongs_to :tutor, class_name: 'User', foreign_key: :tutor_id
  belongs_to :tutee, class_name: 'User', foreign_key: :tutee_id
  belongs_to :availability_manager
  has_many :call_to_users
  has_many :reminder_texts
  after_create :find_start_page, :remove_availability_occurrence
  
  #only allow one appointment per hour per user

  def remove_availability_occurrence
    if tutor.present?
      tutor.availability_manager.remove_occurrence(self.scheduled_for)
    end
    if tutee.present?
      tutee.availability_manager.remove_occurrence(self.scheduled_for)
    end
  end

  def self.batch_for_this_hour
    Appointment.fully_assigned.after(Time.current.beginning_of_hour.utc).before(Time.current.end_of_hour.utc)
  end

  def self.batch_for_pm_reminder_text
    Appointment.fully_assigned
      .where("begin_time between (?) and (?)", Time.current.utc + 16.hours, (Time.current.utc + 16.7.hours))
  end
  
  def self.batch_for_am_reminder_text
    Appointment.fully_assigned.where("begin_time between (?) and (?)", Time.current.utc + 16.hours, (Time.current.utc + 16.7.hours)).
      after(Time.current.end_of_day).before(Time.current.end_of_day + 24.hours)
  end

  def self.batch_for_just_before_reminder_text
    Appointment.fully_assigned.
      where("begin_time between (?) and (?)", Time.current.utc, (Time.current.utc + 40.minutes))
  end

  def find_start_page
    if self.tutee && self.tutee.appointments.present? && self.tutee.appointments.most_recent.present? && self.tutee.appointments.most_recent.first.finish_page.present?
      most_recent_appointment = self.tutee.appointments.most_recent.first  
      self.start_page = most_recent_appointment.finish_page
      self.save
    else
      self.start_page = 1
      self.save
    end
  end

  def self.batch_create(user_id, matches)
    matches.each do |match|
      matching_user_id = match.first.to_i
      matching_time = match.last.to_datetime
      apt = Appointment.new(scheduled_for: matching_time)
      apt.assign_user_role(matching_user_id)
      apt.assign_user_role(user_id.to_i)
      apt.status = 'incomplete'
      apt.save if apt.tutor.present? && apt.tutee.present?
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
    next_appointment if next_appointment.present? && next_appointment.scheduled_for.utc.hour == Time.current.utc.hour
  end

  def self.needs_page_number
    where('status == complete AND finish_page == nil')
  end

  def start_call
  	self.call_to_users.build(tutor_id: tutor.id, tutee_id: tutee.id)
  	self.call_to_users.last.start_call
  end

  def set_status
    if (began_at.present? && ended_at.present?)
      self.status = 'complete' 
    else
      self.status = 'incomplete' 
    end
    self.save
  end
end
