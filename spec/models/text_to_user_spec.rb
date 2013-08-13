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
#

require 'spec_helper'

describe TextToUser do
  it 'has a valid factory' do
    FactoryGirl.create(:text_to_user).should be_valid
  end

  #  describe "#deliver" do
  #  	it 'should create a new text' do
  # 		@joey = FactoryGirl.create(:user, role: 'tutor', cell_number: '2154997415')
  # 		TextToUser.deliver(@joey, 'hello')
  # 		TextToUser.last.body.should eq 'hello'
  # 	end
  # end
end
