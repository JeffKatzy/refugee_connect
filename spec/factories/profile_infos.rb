# == Schema Information
#
# Table name: profile_infos
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  age           :string(255)
#  interests     :text
#  english_focus :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :profile_info do
    user_id 1
    age "MyString"
    interests "MyText"
    english_focus "MyText"
  end
end
