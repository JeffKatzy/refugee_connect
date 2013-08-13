# == Schema Information
#
# Table name: matches
#
#  id         :integer          not null, primary key
#  tutor_id   :integer
#  tutee_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Match < ActiveRecord::Base
  attr_accessible :tutee_id, :tutor_id
end
