# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :text_from_user do
    body "MyText"
    time "2013-08-14 14:27:31"
    user_id 1
  end
end
