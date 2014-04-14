# == Schema Information
#
# Table name: text_coordinators
#
#  id             :integer          not null, primary key
#  appointment_id :integer
#  user_id        :integer
#  text_signup_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class TextCoordinator < ActiveRecord::Base
  attr_accessible :appointment_id, :text_signup_id, :user_id

  def self.coordinate
  	
  end
end
