# == Schema Information
#
# Table name: comments
#
#  id                 :integer          not null, primary key
#  comment_text       :text
#  tutor_id           :integer
#  user_assignment_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  appointment_id     :integer
#  tutee_id           :integer
#  bookpage_id        :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    comment_text "MyText"
    tutor_id 1
    user_assignment_id 1
  end
end
