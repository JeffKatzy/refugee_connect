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

  include IceTime

  attr_accessible :schedule, :user_id, :per_week

  belongs_to :user
  serialize :schedule_hash, Hash
  after_create :init

  def init
    self.per_week ||= 1
  end

  def self.remove_availability(user, appointments_time)
  	manager = AvailabilityManager.find_by_user(user.id)
  	manager.remove_availability(time_period)
  end

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
end
