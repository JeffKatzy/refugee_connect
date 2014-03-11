# == Schema Information
#
# Table name: user_lessons
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  lesson_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserLesson < ActiveRecord::Base
  attr_accessible :lesson_id, :user_id
  has_many :user_assignments
  belongs_to :user

  def finished
  	return true if self.user_assignments(&:status).uniq.first == 'complete'
  	false
  end

  def make_current
  	if status != 'current'
  		self.status = 'current' 
  		self.save
  		ul.instruct_user
  	end
  end

  def instruct_user
  	body = "Next lesson: "
  	self.lesson.assignments(&:instructions).each do |instruction|
  		body += instruction
  	end
  	TextToUser.deliver(user, body)
  end
end
