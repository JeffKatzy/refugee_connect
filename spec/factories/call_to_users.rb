# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :call_to_user do
    tutor_id 1
    tutee_id 1
    begin_time "2013-08-13 17:31:22"
    end_time "2013-08-13 17:31:22"
  end
end
