# == Schema Information
#
# Table name: openings
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  time_open  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  day_open   :string(255)
#

class Opening < ActiveRecord::Base
  attr_accessible :day_open, :time_open, :user_id
  belongs_to :user
  after_create :find_or_create_availability_manager, :add_occurrence_rules

  def find_or_create_availability_manager
  	AvailabilityManager.find_or_create_by_user_id(self.user.id)
  end

  def add_occurrence_rules
  	self.user.availability_manager.add_weekly_availability(self.day_open, self.time_open)
  end
end