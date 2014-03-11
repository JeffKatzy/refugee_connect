	# == Schema Information
#
# Table name: lessons
#
#  id          :integer          not null, primary key
#  name        :text
#  description :text
#  objectives  :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  start_page  :integer
#  finish_page :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lesson do
    name "MyText"
  end
end
