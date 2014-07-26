# == Schema Information
#
# Table name: confirmations
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  specific_opening_id :integer
#  confirmed           :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Confirmation < ActiveRecord::Base
  attr_accessible :confirmed, :specific_opening_id, :user_id
  belongs_to :user
  belongs_to :specific_opening
end
