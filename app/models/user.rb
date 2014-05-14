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
#  twitter_handle   :string(255)
#

class User < ActiveRecord::Base
  has_secure_password
  has_one :availability_manager
  has_one :location
  has_one :facebook_user
  has_one :text_signup

  has_many :text_from_users
  has_many :openings
  has_many :reminder_texts
  has_many :photos
  
  has_many :text_to_users
  
  has_many :appointments_of_tutor, class_name: 'Appointment', foreign_key: :tutor_id, :order => 'scheduled_for DESC'
  has_many :appointments_of_tutee, class_name: 'Appointment', foreign_key: :tutee_id, :order => 'scheduled_for DESC'
  has_many :matches_of_tutor, class_name: 'Match', foreign_key: :tutor_id
  has_many :matches_of_tutee, class_name: 'Match', foreign_key: :tutee_id

  has_many :appointment_partners_of_tutor, :through => :appointments_of_tutor, source: 'appointment_partner_of_tutor', uniq: true
  has_many :appointment_partners_of_tutee, :through => :appointments_of_tutee, source: 'appointment_partner_of_tutee', uniq: true
  has_many :match_partners_of_tutor, :through => :matches_of_tutor, source: 'match_partner_of_tutor', uniq: true
  has_many :match_partners_of_tutee, :through => :matches_of_tutee, source: 'match_partner_of_tutee', uniq: true
  has_many :assignments, through: :user_assignments
  has_many :user_assignments


  attr_accessible :cell_number, :email, :role, :name, :password, :password_confirmation, :openings_attributes, :per_week, :time_zone, :twitter_handle

  scope :tutors, -> { active.where(role: 'tutor') }
  scope :tutees, -> { active.where(role: 'tutee') }
  scope :active, -> { where(active: true) }
  scope :has_availabilities, -> {where(has_availabilities? == true)}

  accepts_nested_attributes_for :openings, reject_if: :all_blank, allow_destroy: true

  after_create :create_availability_manager, :add_per_week_to_availability_manager, :init, :build_matches_for_week, :set_time_zone, :pull_photos
  before_save :format_phone_number
  validate :check_user_twitter, if: :twitter_handle_changed?
  validates :email, uniqueness: true
  validates :cell_number, uniqueness: true

  attr_accessor :new_user
  # validates_plausible_phone :cell_number, :presence => true, :uniqueness => true

  #after_create :set_time_zone if: no_time_zone

  APPOINTMENTS_COUNT_MIN = 1

  def appointments
    if self.is_tutor?
      appointments_of_tutor || appointments_of_tutee
    else
      appointments_of_tutee || appointments_of_tutor
    end
  end

  def appointments=(appointments)
    appointments.each do |appointment|
      appointment.tutor = self if self.role == 'tutor'
      appointment.tutee = self if self.role == 'tutee'
      appointment.save
    end
  end

  def check_user_twitter
    if self.twitter_handle.present?
      Photo.check_user(self)
    end
  end

  def matches
    if self.is_tutor?
      matches_of_tutor || matches_of_tutee
    else
      matches_of_tutee || matches_of_tutor
    end
  end

  def matches=(matches)
    matches.each do |match|
      match.tutor = self if self.role == 'tutor'
      match.tutee = self if self.role == 'tutee'
      match.save
    end
  end

  def set_current_lesson(page_number)
    lesson = Lesson.covers_page(page_number).last
    ul = self.user_lessons.where(lesson_id: lesson.id).first
    ul.make_current
  end

  def appointment_partners
    if self.role == 'tutor'
      self.appointment_partners_of_tutor
    else
      self.appointment_partners_of_tutee
    end
  end

  def match_partners
    if self.role == 'tutor'
      self.match_partners_of_tutor
    else
      self.match_partners_of_tutee
    end
  end

  def init
    self.active ||= true
    self.per_week ||= 1
    self.save
  end

  def add_per_week_to_availability_manager
    self.availability_manager.per_week = self.per_week
    self.availability_manager.save
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

  def wants_more_appointments_before(datetime)
    self.reload
    return true if self.appointments.empty? 
    return true if self.appointments.after(datetime - 7.days).empty?
    self.appointments.after(datetime - 7.days).before(datetime + 23.hours).try(:count) < self.try(:per_week) 
  end

  def too_many_apts_per_week(datetime)
    return false if self.appointments.empty? 
    return false if self.appointments.after(datetime - 7.days).empty?
    self.try(:per_week) < self.appointments.after(datetime - 7.days).
      before(datetime).try(:count)
  end

  def build_matches_for_week
    Match.build_all_matches_for(self, Time.current + 7.days)
  end

  def set_time_zone
    if self.time_zone == nil
      if self.role == 'tutor'
        self.time_zone = 'America/New_York'
      elsif self.role == 'tutee'
        self.time_zone = 'New Delhi'
      end
    end
    self.save
  end

  def set_time_zone_from_number
    if self.cell_number[0] == '1'
      self.role = 'tutor'
      self.time_zone = 'America/New_York'
    elsif self.cell_number[0..1] == '91'
      self.role = 'tutee'
      self.time_zone = 'New Delhi'
    end
    self.save
  end

  def pull_photos
    begin
      Photo.pull_tweets(self)
    rescue
      return
    end
  end

  def self.from_omniauth(auth)
    where(auth.slice(:uid)).first_or_initialize.tap do |user|
      user.uid = auth.uid
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.password = SecureRandom.hex(9)
      user.name = auth.info.name
      user.image = auth.info.image
      user.save
      user.new_user = true
    end
  end

  def incomplete_mobile_signup?
    return false if self.text_signup.nil?
    return true if self.text_signup.status != 'complete'
    false
  end

  def potential_partner_with?(user)
    if self.role == 'tutor' && user.role == 'tutee'
      true
    elsif self.role == 'tutee' && user.role == 'tutor'
      true
    else
      false
    end
  end

  private 

  def format_phone_number
    if self.is_tutor?
      self.cell_number = PhonyRails.normalize_number(cell_number)
    else
      self.cell_number = PhonyRails.normalize_number(cell_number)
    end
  end

  def create_availability_manager
    AvailabilityManager.find_or_create_by_user_id(self.id)
    self.save
  end  

  def check_appointments_number
    errors[:base] << "You must select at least one time that you are available" if self.openings.empty?
  end
end
