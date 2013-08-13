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
  has_many :openings
  has_many :appointments
  has_many :text_to_users
  attr_accessible :cell_number, :email, :password_digest, :role, :name, :password, :password_confirmation, :openings_attributes, :per_week

  scope :tutors, -> { where(role: 'tutor') }
  scope :tutees, -> { where(role: 'tutee') }
  scope :active, -> { where(active: true) }
  scope :has_availabilities, -> {where(has_availabilities? == true)}

  accepts_nested_attributes_for :openings

  after_create :create_availability_manager, :add_per_week_to_availability_manager, :init
    
  def available_this_week?
    if self.availability_manager == nil || self.availability_manager.per_week == nil
      binding.pry if self == main
      user = self
      AvailabilityManager.find_or_create_by_user_id(user.id)
      user.per_week ||= 1
      self.save
      user.availability_manager.per_week = self.per_week
      user.availability_manager.save
      user.available_this_week?
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
      hash = {}
      opposite_active_users.select { |user| user.available_this_week? }.select { |user| self.intersections(user).count > 0 }.each do |user|
        hash[user] = self.intersections(user)
      end
      hash
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
end
