# == Schema Information
#
# Table name: tutoring_sessions
#
#  id          :integer          not null, primary key
#  tutor_id    :integer
#  tutee_id    :integer
#  status      :string(255)
#  time        :datetime
#  start_page  :integer
#  finish_page :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class TutoringSessionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
