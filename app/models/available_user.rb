# == Schema Information
#
# Table name: available_users
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  from       :datetime
#  to         :datetime
#  available  :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AvailableUser < ActiveRecord::Base
  attr_accessible :available, :from, :to, :user_id

  def self.find_available_users(time_one = Time.now, time_two)
  	upcoming_appointments = Appointment.after().before()
  end

  def self.update(appointment, time_frame)
  	AvailableUser.time_frame
  	AvailableUser.find_or_create_by_user(appointment.user)
  end
end
