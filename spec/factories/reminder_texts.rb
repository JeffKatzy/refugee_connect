# == Schema Information
#
# Table name: reminder_texts
#
#  id             :integer          not null, primary key
#  appointment_id :integer
#  time           :datetime
#  user_id        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  category       :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reminder_text do
    appointment_id 1
    time "2013-08-28 22:29:41"
    user_id 1
  end
end
