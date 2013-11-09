require 'faker'

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password 'password'
    cell_number '2154997415'
    name 'jeffers'
    time_zone 'America/New_York'

    factory :tutor_unavailable do
      role 'tutor'
      admin 'active'
      
      after(:create) do |tutor|
        time = DateTime.new 2013,02,14,12,30,00
        tutor.availability_manager = FactoryGirl.build(:availability_manager, per_week: 3, user: tutor)
        tutor.availability_manager.add_weekly_availability('wednesday', time)
        tutor.availability_manager.add_weekly_availability('thursday', time)
        tutor.availability_manager.add_weekly_availability('friday', time)
        tutor.appointments = [ FactoryGirl.build(:appointment_wednesday), FactoryGirl.build(:appointment_thursday), FactoryGirl.build(:appointment_friday)]
      end
    end

    factory :tutor_unavailable_rules do
      #tutor is unavailable: the number of rules is equal to the number of appointments
      role 'tutor'
      admin 'false'
      after(:create) do |tutor|
        time = DateTime.new 2013,02,14,12,30,00
        tutor.availability_manager = FactoryGirl.build(:availability_manager, per_week: 4, user: tutor)
        tutor.availability_manager.add_weekly_availability('thursday', time)
        tutor.availability_manager.add_weekly_availability('friday', time)
        tutor.appointments = [ FactoryGirl.build(:appointment_wednesday), FactoryGirl.build(:appointment_thursday), FactoryGirl.build(:appointment_friday)]
      end
    end

    factory :tutor_available do
      #tutor is available: the number of appointments is fewer than the number of rules and the per_week number
      role 'tutor'
      admin 'false'

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
      
      after(:create) do |tutee|
        time = DateTime.new 2013,02,14,12,30,00
        tutee.availability_manager = FactoryGirl.build(:availability_manager, per_week: 3, user: tutee)
        tutee.availability_manager.add_weekly_availability('wednesday', time)
        tutee.availability_manager.add_weekly_availability('thursday', time)
        tutee.availability_manager.add_weekly_availability('friday', time)
        tutee.appointments = [ FactoryGirl.build(:appointment_wednesday), FactoryGirl.build(:appointment_thursday), FactoryGirl.build(:appointment_friday)]
      end
    end

    factory :tutee_available do
      role 'tutee'
      admin 'false'

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

