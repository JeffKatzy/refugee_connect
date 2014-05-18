# == Schema Information
#
# Table name: specific_openings
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  opening_id     :integer
#  appointment_id :integer
#  scheduled_for  :datetime
#  status         :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :specific_opening do
    user_id 1
    opening_id 1
    appointment_id 1
    scheduled_for "2014-05-17 20:53:13"
  end
end
