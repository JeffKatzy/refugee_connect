# == Schema Information
#
# Table name: text_coordinators
#
#  id             :integer          not null, primary key
#  appointment_id :integer
#  user_id        :integer
#  text_signup_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :text_coordinator do
    appointment_id 1
    user_id 1
    text_signup_id 1
  end
end
