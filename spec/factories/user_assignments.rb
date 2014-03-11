# == Schema Information
#
# Table name: user_assignments
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  assignment_id  :integer
#  status         :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_lesson_id :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_assignment do
    user_id 1
    assignment_id 1
    status "MyString"
  end
end
