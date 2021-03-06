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
  after_create :set_time, :build_specific_opening

  def set_time
	 Time.zone = user.time_zone
	 Chronic.time_class = Time.zone
	 time = Chronic.parse(day_open + " " + time_open)
   self.time = time
   self.save
  end

  def scheduled_for_to_text
    self[:time].in_time_zone(self.user.time_zone).strftime("%l:%M %p")
  end

  def scheduled_for_est
    self.time.in_time_zone("America/New_York")
  end

  def scheduled_for_ist
    self.time.in_time_zone("New Delhi")
  end

  def build_specific_opening
    sob = SpecificOpeningBuilder.new([self])
    sob.build_specific_openings.first
  end
end
