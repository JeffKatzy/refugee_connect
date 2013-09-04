# == Schema Information
#
# Table name: reminder_texts
#
#  id             :integer          not null, primary key
#  appointment_id :integer
#  time           :datetime
#  user_id        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  category       :string(255)
#

require 'spec_helper'

describe ReminderText do
  it 'has a valid factory' do
  	FactoryGirl.create(:reminder_text).should be_valid
  end
end
