# == Schema Information
#
# Table name: availability_managers
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  per_week      :integer
#  schedule_hash :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class AvailabilityManager < ActiveRecord::Base

  attr_accessible :schedule, :user_id, :per_week

  belongs_to :user
  serialize :schedule_hash, Hash
  after_create :init, :init_schedule
  has_many :appointments

  def save_schedule
    self.schedule_hash = self.schedule.to_hash
    self.save
  end

  def schedule
    if @schedule
      @schedule
    elsif schedule_hash
      @schedule = IceCube::Schedule.from_hash(self.schedule_hash)
    else
      nil
    end
  end

  def add_weekly_availability(day, time)
    rule = create_rule(day, time)
    add_recurrence(rule)
  end

  def create_rule(day, time)
    IceCube::Rule.weekly.day(day.downcase.to_sym).hour_of_day(time.hour).minute_of_hour(time.min).second_of_minute(0)
  end

  def add_recurrence(rule)
    schedule.add_recurrence_rule rule
    save_schedule
  end

  def remove_occurrence(datetime)
    schedule.add_exception_time(datetime)
    save_schedule
  end

  def occurrence_rules
    schedule.recurrence_rules
  end 

  def remaining_occurrences(datetime)
    occurrences = schedule.occurrences(datetime).select { |time| time > Time.current }
    occurrences - user.appointments.after(Time.current).before(datetime).map(&:scheduled_for)
  end

  def available_before?(datetime)
    if self.remaining_occurrences(datetime) && user.wants_more_appointments_before(datetime)
      return true
    else
      return false
    end
  end

  private

  def init
    self.per_week ||= 1
  end

  def init_schedule
    @schedule = IceCube::Schedule.new(duration: 3600)
    @schedule.start_time = Time.current.in_time_zone("UTC") - 1.day
    save_schedule
  end

  def convert_to_time(hour)
    Time.now.change({:hour => hour.to_i,
      :min => 0, :sec => 0 })
  end
end
