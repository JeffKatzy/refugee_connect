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
  attr_accessible :finish_page, :start_page, :status, :scheduled_for, :tutor_id, :began_at, :ended_at, :tutee_id, :availability_manager_id, :scheduled_for_date_part, :scheduled_for_time_part

  default_scope where("tutee_id IS NOT NULL AND tutor_id IS NOT NULL")
  scope :after, ->(time) { where("scheduled_for >= ?", time) }
  scope :before, ->(time) { where("scheduled_for <= ?", time) }
  scope :during, ->(time) { where("scheduled_for between (?) and (?)", time, time + 1.hour) }
  scope :this_week, after(Time.current.utc.beginning_of_week).before(Time.current.utc.end_of_week)
  scope :recent_inclusive, :limit => 1, :order => 'began_at DESC'
  
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
  belongs_to :availability_manager
  belongs_to :match
  belongs_to :lesson
  has_many :call_to_users
  has_many :reminder_texts
  has_many :text_from_users
  has_many :text_to_users
  after_create :find_start_page, :make_incomplete, :make_match_unavailable, :send_confirmation_text
  validates :tutor, presence: true
  validates :tutee, presence: true
  validate :too_many_apts
  #validate :user_booked_at_that_time
   validate :available_users
  
  #only allow one appointment per hour per user

  def self.auto_batch_create(h = {})
    h[:users] ||= User.tutees.active
    h[:time]  ||= Time.current.end_of_week
    h[:users].each do |user|
      if user.wants_more_appointments_before(h[:time])
        Match.build_all_matches_for(user, h[:time]) if user.matches.available_until(h[:time]).empty? #should this be changed to, if user wants more matches
        @available_matches = user.reload.matches.available_until(h[:time])
        
        if @available_matches.present?
          matches = user.matches.available.where(tutee_id: user.appointment_partners).available_until(h[:time]) if user.is_tutor? #similarly to above comment, we still want matches if wants more
          matches = user.matches.available.where(tutor_id: user.appointment_partners).available_until(h[:time]) if !user.is_tutor?
          matches = @available_matches if matches.empty?
          matches.each do |match|
            match.convert_to_apt 
          end
        end
      end
    end
  end


  def self.batch_create(matches)
    apts = []
    matches.each do |match|
      apt = match.convert_to_apt
      apts << apt
    end
    apts
  end

  def self.batch_for_this_hour
    Appointment.fully_assigned.after(Time.current.beginning_of_hour.utc).before(Time.current.end_of_hour.utc)
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

  def find_start_page
    self.tutee.reload
    if self.tutee && self.tutee.appointments.present? && self.tutee.appointments.most_recent.present? && self.tutee.appointments.most_recent.first.finish_page.present?
      most_recent_appointment = self.tutee.appointments.most_recent.first  
      self.start_page = most_recent_appointment.finish_page
      self.save
    else
      self.start_page = 1
      self.save
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

  def start_call
    self.began_at = Time.current
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

  def make_match_unavailable
    self.match.update_attributes(available: false)
  end

  def sign_up_message_for(user)
    if user.role == 'tutor'
      self[:scheduled_for].in_time_zone(user.time_zone).strftime("You now have an appointment scheduled with #{self.tutee.name} at %I:%M%p on %A.")
    else
      self[:scheduled_for].in_time_zone(user.time_zone).strftime("You now have an appointment scheduled with #{self.tutor.name} at %I:%M%p on %A.")
    end
  end

  def send_confirmation_text
    tutor_body = self.sign_up_message_for(self.tutor)
    tutee_body = self.sign_up_message_for(self.tutee)
    # tutee_body = self[:scheduled_for].in_time_zone(self.tutee.time_zone).strftime("You have have an appointment scheduled with #{self.tutor.name} at %I:%M%p on %A.")
    begin
      TextToUser.deliver(self.tutor, tutor_body)
      TextToUser.deliver(self.tutee, tutee_body)
    rescue
      "Failed in sending to user #{self.tutee.name} or #{self.tutor.name}"
    end
  end

  def available_users
    if self.tutor.present? && self.tutee.present?
      if self.tutor.appointments.scoped.during(self.scheduled_for).reject { |a| a == self }.present? || self.tutee.appointments.scoped.during(self.scheduled_for).reject {|a| a == self }.present?
        errors[:base] << "A tutor or tutee is already scheduled at that time."
      end
    end
  end

  def too_many_apts
    if self.tutor.present? && self.tutee.present?
      if (self.tutor.too_many_apts_per_week(self.scheduled_for) || self.tutee.too_many_apts_per_week(self.scheduled_for) )
        errors[:base] << "Both tutor and tutee must want more apppointments."
      end
    end
  end

  def scheduled_for_to_text(user_role)
    if user_role == 'tutor'
      self[:scheduled_for].in_time_zone(tutor.time_zone).strftime("%I:%M%p beginning")
    elsif user_role == 'tutee'
      self[:scheduled_for].in_time_zone(tutee.time_zone).strftime("%I:%M%p beginning")
    else
      raise 'Must pass in either tutor or tutee'
    end
  end
end
