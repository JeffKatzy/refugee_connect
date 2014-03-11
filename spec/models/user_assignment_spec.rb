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

require 'spec_helper'

describe UserAssignment do
  pending "add some examples to (or delete) #{__FILE__}"
end
