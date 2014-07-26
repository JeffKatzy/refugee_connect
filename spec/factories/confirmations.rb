# == Schema Information
#
# Table name: confirmations
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  specific_opening_id :integer
#  confirmed           :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :confirmation do
    user_id 1
    specific_opening_id 1
    confirmed false
  end
end
