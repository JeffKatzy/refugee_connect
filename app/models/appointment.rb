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
#  user_id       :integer
#  began_at      :datetime
#  ended_at      :datetime
#  scheduled_for :datetime
#

class Appointment < ActiveRecord::Base
  attr_accessible :finish_page, :start_page, :status, :scheduled_for, :user_id, :began_at, :ended_at
  
  scope :after, ->(time) { where("scheduled_for > ?", time) }
  scope :before, ->(time) { where("scheduled_for < ?", time) }
  scope :this_week, after(Time.now.utc.beginning_of_week).before(Time.now.utc.end_of_week)
  scope :most_recent, :limit => 1, :order => 'began_at DESC'
  
  #perhaps make incomplete the default scope
  scope :this_hour, after(Time.now.beginning_of_hour).before(Time.now.end_of_hour)  #for some reason this was not working
  scope :incomplete, where(status: 'incomplete')
  scope :complete, where(status: 'complete')
  scope :needs_text, complete.where("finish_page IS NULL")
  scope :next_appointments, incomplete.order(:scheduled_for)
  #check to see if this still works
  belongs_to :user


  belongs_to :tutor, class_name: 'User', foreign_key: :tutor_id
  belongs_to :tutee, class_name: 'User', foreign_key: :tutee_id


  has_many :call_to_users

  #only allow one appointment per hour per user

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
