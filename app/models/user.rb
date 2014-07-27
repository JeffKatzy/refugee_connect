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

  has_many :appointment_partners_of_tutor, :through => :appointments_of_tutor, source: 'appointment_partner_of_tutor', uniq: true
  has_many :appointment_partners_of_tutee, :through => :appointments_of_tutee, source: 'appointment_partner_of_tutee', uniq: true
  has_many :assignments, through: :user_assignments
  has_many :user_assignments
  has_many :specific_openings


  attr_accessible :cell_number, :email, :role, :name, :password, :password_confirmation, :openings_attributes, :time_zone, :twitter_handle

  accepts_nested_attributes_for :openings, reject_if: :all_blank, allow_destroy: true

  scope :tutors, -> { active.where(role: 'tutor') }
  scope :tutees, -> { active.where(role: 'tutee') }
  scope :active, -> { where(active: true) }

  after_create :init, :set_time_zone, :pull_photos
  before_save :format_phone_number
  validate :check_user_twitter, if: :twitter_handle_changed?
  validates :email, uniqueness: true
  validates :cell_number, uniqueness: true

  attr_accessor :new_user
  # validates_plausible_phone :cell_number, :presence => true, :uniqueness => true
  #after_create :set_time_zone if: no_time_zone

  APPOINTMENTS_COUNT_MIN = 1

  def init
    self.active ||= true
    self.save
  end

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

  def appointment_partners
    if self.role == 'tutor'
      partners = self.appointment_partners_of_tutor
    else
      partners = self.appointment_partners_of_tutee
    end
      partners.reject! {|u| u.id == self.id }
      partners
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

  def set_current_lesson(page_number)
    lesson = Lesson.covers_page(page_number).last
    ul = self.user_lessons.where(lesson_id: lesson.id).first
    ul.make_current
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

  def format_phone_number
    if self.is_tutor?
      self.cell_number = self.cell_number.phony_formatted(normalize: :US, format: :international, spaces: "")
    else
      self.cell_number = self.cell_number.phony_formatted(normalize: :IN, format: :international, spaces: "")
    end
  end

  def check_appointments_number
    errors[:base] << "You must select at least one time that you are available" if self.openings.empty?
  end
end
