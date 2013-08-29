# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reminder_text do
    appointment_id 1
    time "2013-08-28 22:29:41"
    user_id 1
    reminder_type "MyString"
  end
end
