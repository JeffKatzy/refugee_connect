# == Schema Information
#
# Table name: available_times
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  time_available :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  weekday        :string(255)
#  hour           :string(255)
#  schedule       :text
#

require 'test_helper'

class AvailableTimeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
