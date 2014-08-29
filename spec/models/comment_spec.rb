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
#  appointment_id     :integer
#  tutee_id           :integer
#  bookpage_id        :integer
#

require 'spec_helper'

describe Comment do
  pending "add some examples to (or delete) #{__FILE__}"
end
