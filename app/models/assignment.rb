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
  attr_accessible :instructions, :lesson_id, :bookpages_attributes

  belongs_to :lesson
  has_many :users, through: :user_assignments
  has_many :bookpages

  accepts_nested_attributes_for :bookpages, reject_if: :all_blank, allow_destroy: true
end
