# == Schema Information
#
# Table name: bookpages
#
#  id            :integer          not null, primary key
#  title         :string(255)
#  page_number   :integer
#  image         :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  assignment_id :integer
#  teachers_page :boolean
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :bookpage do
    title "MyString"
    page_number 1
    image "MyString"
  end
end
