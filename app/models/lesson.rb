# == Schema Information
#
# Table name: lessons
#
#  id          :integer          not null, primary key
#  name        :text
#  description :text
#  objectives  :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  start_page  :integer
#  finish_page :integer
#

class Lesson < ActiveRecord::Base
  attr_accessible :name, :description, :assignments_attributes
  has_many :appointments
  has_many :assignments
  accepts_nested_attributes_for :appointments, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :assignments, reject_if: :all_blank, allow_destroy: true
  scope :covers_page, ->(page_number) { where("start_page <= ?", page_number).where("finish_page >= ?", page_number) }
end
