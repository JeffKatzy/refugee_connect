# Read about factories at https://github.com/thoughtbot/factory_girl
# == Schema Information
#
# Table name: availability_managers
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  per_week      :integer
#  schedule_hash :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null

FactoryGirl.define do
  factory :availability_manager do
  	association :user
    per_week 3

    factory :wednesday do
	    after(:build) do |wednesday|
	    	wednesday.add_weekly_availability('wednesday', 4)
	    end 
    end

    factory :thursday do
    	after(:build) do |thursday|
    		thursday.add_weekly_availability('thursday', 4)
    	end
    end

    factory :friday do
    	after(:build) do |friday|
    		friday.add_weekly_availability('friday', 4)
    	end
    end
  end
end
