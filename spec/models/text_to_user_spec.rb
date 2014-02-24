# == Schema Information
#
# Table name: text_to_users
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  time       :datetime
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  received   :string(255)
#

require 'spec_helper'

describe TextToUser do
  it 'has a valid factory' do
    FactoryGirl.create(:text_to_user).should be_valid
  end
end
