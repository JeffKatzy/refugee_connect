# == Schema Information
#
# Table name: comments
#
#  id                 :integer          not null, primary key
#  comment_text       :text
#  tutor_id           :integer
#  user_assignment_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Comment < ActiveRecord::Base
  attr_accessible :comment_text, :tutor_id, :user_assignment_id
  belongs_to :tutor
  belongs_to :user_assignment
end
