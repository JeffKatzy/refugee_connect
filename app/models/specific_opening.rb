# == Schema Information
#
# Table name: specific_openings
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  opening_id     :integer
#  appointment_id :integer
#  scheduled_for  :datetime
#  status         :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class SpecificOpening < ActiveRecord::Base
  attr_accessible :appointment_id, :opening_id, :scheduled_for, :user_id, :opening_status

  def self.build_specific_openings
  	User.active
  end
end
