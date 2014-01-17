require 'faker'

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password 'password'
    name 'jeffers'
    cell_number '2154997415'

    factory :tutor_unavailable do
      role 'tutor'
      admin 'active'
      time_zone 'America/New_York'
      cell_number '2154997415'
      
      after(:create) do |tutor|
        time = DateTime.new 2013,02,14,12,30,00
        tutor.availability_manager = FactoryGirl.build(:availability_manager, per_week: 3, user: tutor)
        tutor.availability_manager.add_weekly_availability('wednesday', time)
        tutor.availability_manager.add_weekly_availability('thursday', time)
        tutor.availability_manager.add_weekly_availability('friday', time)
        [ FactoryGirl.build(:appointment_wednesday), FactoryGirl.build(:appointment_thursday), FactoryGirl.build(:appointment_friday)].each do |apt|
          tutor.appointments << apt
        end
      end
    end

    factory :tutor_unavailable_rules do
      role 'tutor'
      admin 'false'
      time_zone 'America/New_York'
      cell_number '2154997415'

      after(:create) do |tutor|
        time = DateTime.new 2013,02,14,12,30,00
        tutor.availability_manager = FactoryGirl.build(:availability_manager, per_week: 4, user: tutor)
        tutor.availability_manager.add_weekly_availability('thursday', time)
        tutor.availability_manager.add_weekly_availability('friday', time)
        tutor.appointments << [ FactoryGirl.build(:appointment_wednesday), FactoryGirl.build(:appointment_thursday), FactoryGirl.build(:appointment_friday)]
      end
    end

    factory :tutor_available do
      #tutor is available: the number of appointments is fewer than the number of rules and the per_week number
      role 'tutor'
      admin 'false'
      time_zone 'America/New_York'
      cell_number '2154997415'
      per_week 5

      after(:create) do |tutor|
        time = DateTime.new 2013,02,14,12,30,00
        tutor.availability_manager = FactoryGirl.build(:availability_manager, per_week: 4, user: tutor)
        tutor.availability_manager.add_weekly_availability('wednesday', time)
        tutor.availability_manager.add_weekly_availability('thursday', time)
        tutor.availability_manager.add_weekly_availability('friday', time)
      end
    end

    factory :tutee_unavailable do
      role 'tutee'
      admin 'false'
      time_zone "New Delhi"
      cell_number '+91 97960 97962'
      per_week '3'
        
      after(:create) do |tutee|
        time = DateTime.new 2013,02,14,12,30,00
        tutee.availability_manager = FactoryGirl.build(:availability_manager, per_week: 3, user: tutee)
        tutee.availability_manager.add_weekly_availability('wednesday', time)
        tutee.availability_manager.add_weekly_availability('thursday', time)
        tutee.availability_manager.add_weekly_availability('friday', time)
        FactoryGirl.create(:appointment_wednesday, tutee: tutee)
        FactoryGirl.create(:appointment_thursday, tutee: tutee)
        FactoryGirl.create(:appointment_friday, tutee: tutee)
      end
    end

    factory :tutee_available do
      role 'tutee'
      admin 'false'
      cell_number '+91 97960 97962'
      time_zone "New Delhi"
      per_week 5

      after(:create) do |tutee|
        time = DateTime.new 2013,02,14,12,30,00
        tutee.availability_manager = FactoryGirl.build(:sunday, per_week: 4, user: tutee)
        tutee.availability_manager.add_weekly_availability('wednesday', time)
        tutee.availability_manager.add_weekly_availability('thursday', time)
        tutee.availability_manager.add_weekly_availability('friday', time)
      end
    end
  end
end

