# == Schema Information
#
# Table name: assignments
#
#  id           :integer          not null, primary key
#  instructions :text
#  lesson_id    :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :assignment do
    instructions "MyText"
    lesson_id 1
  end
end
