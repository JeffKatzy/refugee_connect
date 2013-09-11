# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email           :string(255)
#  password_digest :string(255)
#  cell_number     :string(255)
#  role            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  admin           :boolean
#  name            :string(255)
#  active          :boolean
#  per_week        :integer
#

class User < ActiveRecord::Base
  has_secure_password
  has_one :availability_manager
  has_many :text_from_users
  has_many :openings
  has_many :reminder_texts
  
  has_many :text_to_users
  attr_accessible :cell_number, :email, :role, :name, :password, :password_confirmation, :openings_attributes, :per_week

  scope :tutors, -> { where(role: 'tutor') }
  scope :tutees, -> { where(role: 'tutee') }
  scope :active, -> { where(active: true) }
  scope :has_availabilities, -> {where(has_availabilities? == true)}

  accepts_nested_attributes_for :openings


  after_create :create_availability_manager, :add_per_week_to_availability_manager, :init
  before_save :format_phone_number
  validates_plausible_phone :cell_number, :presence => true



  def appointments
    Appointment.where('tutor_id = :user_id or tutee_id = :user_id', user_id: self.id)
  end

  def is_tutor?
    if self.role == 'tutor'
      true
    else
      false
    end
  end

  def format_cell_number
    self.cell_number.gsub(/[^0-9]/, "")
  end

  def last_page_completed
    self.appointments.most_recent.first.finish_page
  end

    
  def available_this_week?
    if self.availability_manager == nil || self.availability_manager.per_week == nil
      AvailabilityManager.find_or_create_by_user_id(self.id)
      self.per_week ||= 1
      self.save
      self.availability_manager.per_week = self.per_week
      self.availability_manager.save
      self.available_this_week?
  	elsif (appointments.this_week.count < self.availability_manager.try(:occurrence_rules).try(:count)) && (appointments.before(Time.now.end_of_week).try(:count) < availability_manager.try(:per_week))
      return true
    elsif availability_manager.per_week == appointments.before(Time.now.end_of_week).count
      return false
    else
      return 'overbooked'
  	end
  end
  
  def intersections(second_user)
  	arr = []
  	user_availabilities = self.availability_manager.remaining_occurrences_this_week
  	user_availabilities.each do |time|
  		arr << time if second_user.availability_manager.schedule.occurring_at?(time)
  	end 
    arr
  end

  def opposite_active_users
    if self.role == 'tutor'
      users = User.tutees.active
    elsif self.role == 'tutee'
      users = User.tutors.active
    else
      return 'role must be either tutor or tutee'
    end
  end

  def available_appointments_this_week
    if self.available_this_week?
      arr = []
      opposite_active_users.select { |user| user.available_this_week? }.select { |user| self.intersections(user).count > 0 }.each do |user|
        hsh = { user: user, times: self.intersections(user)}
        arr << hsh
      end
      arr
    else
      return 'user has no remaining availabilities this week.'
    end
  end

  def add_per_week_to_availability_manager
    self.availability_manager.per_week = self.per_week
    self.availability_manager.save
  end  

  def create_availability_manager
    AvailabilityManager.find_or_create_by_user_id(self.id)
    self.save
  end

  def init
    self.active = true
    self.per_week ||= 1
    self.save
  end

  private 

  def format_phone_number
    if self.is_tutor?
      self.cell_number = PhonyRails.normalize_number(cell_number, :country_code => 'US')
    else
      self.cell_number = PhonyRails.normalize_number(cell_number, :country_code => 'IN')
    end
  end
end
