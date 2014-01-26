# == Schema Information
#
# Table name: users
#
#  id               :integer          not null, primary key
#  email            :string(255)
#  password_digest  :string(255)
#  cell_number      :string(255)
#  role             :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  admin            :boolean
#  name             :string(255)
#  active           :boolean
#  per_week         :integer
#  uid              :string(255)
#  oauth_token      :string(255)
#  oauth_expires_at :datetime
#  image            :string(255)
#  time_zone        :string(255)
#  twitter_handle   :string(255)
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
