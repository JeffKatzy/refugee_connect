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

    factory :sunday do
      after(:create) do |sunday|
        time = DateTime.new 2013,02,14,12,30,00
        sunday.add_weekly_availability('sunday', time)
      end 
    end

    factory :monday do
      after(:create) do |monday|
        time = DateTime.new 2013,02,14,12,30,00
        monday.add_weekly_availability('monday', time)
      end 
    end

    factory :wednesday do
      after(:create) do |wednesday|
        time = DateTime.new 2013,02,14,12,30,00
        wednesday.add_weekly_availability('wednesday', time)
      end 
    end

    factory :thursday do
    	after(:create) do |thursday|
        time = DateTime.new 2013,02,14,12,30,00
    		thursday.add_weekly_availability('thursday', time)
    	end
    end

    factory :friday do
    	after(:create) do |friday|
        time = DateTime.new 2013,02,14,12,30,00
    		friday.add_weekly_availability('friday', time)
    	end
    end
  end
end
