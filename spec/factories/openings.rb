# == Schema Information
#
# Table name: openings
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  day_open   :string(255)
#  time       :datetime
#  time_open  :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :opening do
  	day_open 'Sunday'
  	time_open '9:30 pm'
  	time Time.current.change(weekday: 'Sunday', hour: 21, minute: 30)
  	user { FactoryGirl.create :tutor_available }
  end
end
