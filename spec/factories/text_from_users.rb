# == Schema Information
#
# Table name: text_from_users
#
#  id              :integer          not null, primary key
#  body            :text
#  time            :datetime
#  user_id         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  incoming_number :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :text_from_user do
    body "MyText"
    time "2013-08-14 14:27:31"
    user_id 1
  end
end
