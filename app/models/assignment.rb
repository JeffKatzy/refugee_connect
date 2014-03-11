# == Schema Information
#
# Table name: assignments
#
#  id           :integer          not null, primary key
#  instructions :text
#  lesson_id    :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Assignment < ActiveRecord::Base
  attr_accessible :instructions, :lesson_id

  belongs_to :lesson
  has_many :users, through: :user_assignments
end
