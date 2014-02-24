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

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :text_to_user do
    user_id 1
    time "2013-08-13 12:27:52"
    body "MyText"
  end
end
