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
#  match_id      :integer
#  lesson_id     :integer
#

class Appointment < ActiveRecord::Base
  include MultiparameterDateTime
  attr_accessible :finish_page, :start_page, :status, :scheduled_for, :tutor_id, :began_at, :ended_at, :tutee_id, :scheduled_for_date_part, :scheduled_for_time_part

  default_scope where("tutee_id IS NOT NULL AND tutor_id IS NOT NULL")
  scope :after, ->(time) { where("scheduled_for >= ?", time) }
  scope :before, ->(time) { where("scheduled_for <= ?", time) }
  scope :during, ->(time) { where("scheduled_for between (?) and (?)", time, time + 1.hour) }
  scope :this_week, after(Time.current.utc.beginning_of_week).before(Time.current.utc.end_of_week)
  scope :today, after(Time.current.utc.beginning_of_day).before(Time.current.utc.end_of_day)
  scope :recent_inclusive, where('began_at IS NOT NULL order by began_at desc limit 1')
  
  scope :tomorrow, after(Time.current.utc.end_of_day).before(Time.current.utc.end_of_day + 24.hours)
  scope :incomplete, where(status: 'incomplete')
  scope :complete, where(status: 'complete')
  scope :needs_text, complete.where("finish_page IS NULL")
  scope :next_appointments, incomplete.after(Time.current.utc).order(:scheduled_for)
  scope :in_half_a_day, where("scheduled_for between (?) and (?)", Time.current.utc + 16.hours, (Time.current.utc + 16.7.hours))
  scope :in_forty_minutes, where("scheduled_for between (?) and (?)", Time.current.utc, (Time.current.utc + 40.minutes))
  scope :fully_assigned, where("tutee_id IS NOT NULL AND tutor_id IS NOT NULL")
  scope :unstarted, where("began_at IS NULL")

  scope :most_recent, complete.recent_inclusive

  scope :this_hour, where("scheduled_for between (?) and (?)", Time.current.utc.beginning_of_hour, Time.current.utc.end_of_hour)
  scope :next_hour, where("scheduled_for between (?) and (?)", Time.current.utc.beginning_of_hour + 1.hour, Time.current.utc.end_of_hour + 1.hour)
  
  #check to see if this still works

   multiparameter_date_time :scheduled_for_est
   multiparameter_date_time :scheduled_for
   multiparameter_date_time :scheduled_for_ist

  belongs_to :user
  belongs_to :appointment_partner_of_tutor, class_name: 'User', foreign_key: :tutee_id
  belongs_to :appointment_partner_of_tutee, class_name: 'User', foreign_key: :tutor_id
  belongs_to :tutor, class_name: 'User', foreign_key: :tutor_id
  belongs_to :tutee, class_name: 'User', foreign_key: :tutee_id
  belongs_to :lesson
  has_many :call_to_users
  has_many :reminder_texts
  has_many :text_from_users
  has_many :text_to_users
  has_many :specific_openings
  has_many :texts, as: :unit_of_work
  after_create :make_incomplete
  validates :tutor, presence: true
  validates :tutee, presence: true
  
  #only allow one appointment per hour per user

  def self.batch_for_begin_text
    Appointment.fully_assigned.unstarted.after(Time.current.utc.beginning_of_hour).before(Time.current.utc)
  end

  def self.batch_for_one_day_from_now
    Appointment.fully_assigned.where("scheduled_for between (?) and (?)", 
      (Time.current.utc + 24.hours).beginning_of_hour, (Time.current.utc + 24.hours).end_of_hour)
  end

  def scheduled_for_est
    self.scheduled_for.in_time_zone("America/New_York")
  end

  def scheduled_for_ist
    self.scheduled_for.in_time_zone("New Delhi")
  end

  def scheduled_for_to_text(user_role)
    if user_role == 'tutor'
      self[:scheduled_for].in_time_zone(self.tutor.time_zone).strftime("%l:%M %p on %A beginning")
    elsif user_role == 'tutee'
      self[:scheduled_for].in_time_zone(self.tutee.time_zone).strftime("%l:%M %p on %A beginning")
    else
      raise 'Must pass in either tutor or tutee'
    end
  end

  def set_scheduled_for_est(params)
    if params[:scheduled_for_est_time_part]
      new_time = Chronic.parse(params[:scheduled_for_est_time_part])
      old_time = Chronic.parse(self.scheduled_for_est_time_part)
      self.advance(old_time, new_time)
      self.save(validate: false)
    else params[:scheduled_for_est_date_part]
      self.scheduled_for = (Time.parse(params[:scheduled_for_est_date_part] + " " + scheduled_for_est_time_part + " est")).utc
      self.save
    end
  end

  def set_scheduled_for_ist(params)
    if params[:scheduled_for_ist_time_part]
      new_time = Chronic.parse(params[:scheduled_for_ist_time_part])
      old_time = Chronic.parse(self.scheduled_for_ist_time_part)
      self.advance(old_time, new_time)
      self.save(validate: false)
    else params[:scheduled_for_ist_date_part]
      self.scheduled_for = (Time.parse(params[:scheduled_for_ist_date_part] + " " + scheduled_for_ist_time_part + " ist")).utc
      self.save
    end
  end

  def advance(old_time, new_time)
    diff_in_hours = (new_time - old_time)/(60*60)
    self.scheduled_for += diff_in_hours.hours
  end

  def self.batch_for_just_before
    Appointment.fully_assigned.next_hour
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

  def assign_user_role(user_id)
    user = User.find(user_id)
    if user.is_tutor?
      self.tutor = user
    else 
      self.tutee = user
    end
    self.save
  end

  def start_call
    #move begin date to the call itself. 
    self.began_at = Time.current.utc
    self.status = 'In Progress'
    self.save

  	self.call_to_users.build(tutor_id: self.tutor.id, tutee_id: self.tutee.id)
  	self.call_to_users.last.start_call
  end

  def complete
    self.ended_at = Time.current.utc
    self.save
    self.set_status
    TextToUser.deliver(self.tutor, 'Please text the page number that you last left off at.')
  end

  def set_status
    if (began_at.present? && ended_at.present?)
      self.status = 'complete' 
    else
      self.status = 'incomplete' 
    end
    self.save
  end

  def make_incomplete
    self.status = 'incomplete'
  end
end
