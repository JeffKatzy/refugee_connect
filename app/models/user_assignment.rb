# == Schema Information
#
# Table name: user_assignments
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  assignment_id  :integer
#  status         :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_lesson_id :integer
#

class UserAssignment < ActiveRecord::Base
  attr_accessible :assignment_id, :status, :user_id
  belongs_to :user
  belongs_to :assignment
  has_many :comments
end
