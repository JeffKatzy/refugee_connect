# == Schema Information
#
# Table name: photos
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  url              :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  tweet_id         :integer
#  tweet_created_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :photo do
    user_id 1
    url "MyText"
  end
end
