# == Schema Information
#
# Table name: users
#
#  id               :integer          not null, primary key
#  email            :string(255)
#  password_digest  :string(255)
#  cell_number      :string(255)
#  role             :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  admin            :boolean
#  name             :string(255)
#  active           :boolean
#  per_week         :integer
#  uid              :string(255)
#  oauth_token      :string(255)
#  oauth_expires_at :datetime
#  image            :string(255)
#  time_zone        :string(255)
#

class User < ActiveRecord::Base
  has_secure_password
  has_one :availability_manager
  has_many :text_from_users
  has_many :openings
  has_many :reminder_texts
  
  has_many :text_to_users
  attr_accessible :cell_number, :email, :role, :name, :password, :password_confirmation, :openings_attributes, :per_week, :time_zone

  scope :tutors, -> { active.where(role: 'tutor') }
  scope :tutees, -> { active.where(role: 'tutee') }
  scope :active, -> { where(active: true) }
  scope :has_availabilities, -> {where(has_availabilities? == true)}

  accepts_nested_attributes_for :openings, reject_if: :all_blank, allow_destroy: true


  after_create :create_availability_manager, :add_per_week_to_availability_manager, :init
  before_save :format_phone_number
  validates_plausible_phone :cell_number, :presence => true

  def init
    self.active ||= true
    self.per_week ||= 1
    self.save
  end

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end

  def facebook
    @facebook ||= Koala::Facebook::API.new(oauth_token)
  end

  def friends
    facebook.fql_query('SELECT name, pic_square, uid FROM user WHERE uid in (SELECT uid2 FROM friend WHERE uid1=me())')
  end

  def college_friends
    query(self.college, 'education')
  end

  def appointments
    Appointment.where('tutor_id = :user_id or tutee_id = :user_id', user_id: self.id)
  end

  def appointments=(appointments)
    appointments.each do |appointment|
      appointment.tutor = self if self.role == 'tutor'
      appointment.tutee = self if self.role == 'tutee'
      appointment.save
    end
  end


  def is_tutor?
    if self.role == 'tutor'
      true
    else
      false
    end
  end

  def last_page_completed
    self.appointments.most_recent.first.finish_page
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

  def available_appointments_before(datetime)
    if self.available_before?(datetime)
      arr = []
      opposite_active_users.select { |user| user.available_before?(datetime) }.select { |user| self.intersections(user, datetime).count > 0 }.each do |user|
        hsh = { user_id: user.id, user_name: user.name, times: self.intersections(user, datetime)}
        arr << hsh
      end
      return arr.take(5) if arr.count > 4
      arr.take(5) 
    else
      []
    end
  end

  def intersections(second_user, datetime)
    arr = []
    availability_manager.remaining_occurrences(datetime).each do |start_time|
      end_time = start_time + 1.hour
      arr << start_time if second_user.availability_manager.schedule.occurring_between?(start_time, end_time)
    end 
    arr
  end

  def available_before?(datetime)
    check_availability_manager
    if availability_manager.remaining_occurrences(datetime) && appointments_less_than_accepted_amount(datetime)
      return true
    else
      return false
    end
  end

  def appointments_less_than_accepted_amount(datetime)
    appointments.after(Time.current).before(datetime).try(:count) < 
      self.try(:per_week) * ((datetime.to_date - Time.current.to_date).to_i/6.round(2))
  end

  def add_per_week_to_availability_manager
    self.availability_manager.per_week = self.per_week
    self.availability_manager.save
  end  

  private 

  def format_phone_number
    if self.is_tutor?
      self.cell_number = PhonyRails.normalize_number(cell_number, :country_code => 'US')
    else
      self.cell_number = PhonyRails.normalize_number(cell_number, :country_code => 'IN')
    end
  end

  def check_availability_manager
    if self.availability_manager == nil || self.availability_manager.per_week == nil
      am = AvailabilityManager.find_or_create_by_user_id(self.id)
      am.per_week ||= 1
      am.save
    end
    true
  end

  def create_availability_manager
    AvailabilityManager.find_or_create_by_user_id(self.id)
    self.save
  end
end
