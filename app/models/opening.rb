# == Schema Information
#
# Table name: openings
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  day_open   :string(255)
#  time       :datetime
#  time_open  :string(255)
#

class Opening < ActiveRecord::Base
  attr_accessible :day_open, :time_open, :user_id
  belongs_to :user
  has_many :specific_openings
  after_create :set_time, :find_or_create_availability_manager, :add_occurrence_rules, :build_specific_opening

  def set_time
	 Time.zone = user.time_zone
	 Chronic.time_class = Time.zone
	 self.time = Chronic.parse(day_open + " " + time_open)
   self.save
  end

  def find_or_create_availability_manager
  	AvailabilityManager.find_or_create_by_user_id(self.user.id)
  end

  def add_occurrence_rules
    weekday = self.time.utc.strftime("%A")
  	self.user.availability_manager.add_weekly_availability(weekday, self.time.utc)
  end

  def build_specific_opening
    sob = SpecificOpeningBuilder.new([self])
    sob.build_specific_openings.first
  end
end
