require 'faker'

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password 'password'
    cell_number '+12154997415'
    active true

    factory :tutor_unavailable do
      role 'tutor'
      admin 'active'
      
      after(:create) do |tutor|
        tutor.availability_manager = FactoryGirl.build(:availability_manager, per_week: 3, user: tutor)
        tutor.availability_manager.add_weekly_availability('wednesday', 4)
        tutor.availability_manager.add_weekly_availability('thursday', 4)
        tutor.availability_manager.add_weekly_availability('friday', 4)
        [:appointment_wednesday, :appointment_thursday, :appointment_friday].each do |appointment|
          tutor.appointments << FactoryGirl.build(appointment, user: tutor)
        end
      end
    end

    factory :tutor_unavailable_rules do
      #tutor is unavailable: the number of rules is equal to the number of appointments
      role 'tutor'
      admin 'false'

      after(:create) do |tutor|
        tutor.availability_manager = FactoryGirl.build(:availability_manager, per_week: 4, user: tutor)
        tutor.availability_manager.add_weekly_availability('thursday', 4)
        tutor.availability_manager.add_weekly_availability('friday', 4)
          [:appointment_thursday, :appointment_friday].each do |appointment|
          tutor.appointments << FactoryGirl.build(appointment, user: tutor)
        end
      end
    end

    factory :tutor_available do
      #tutor is available: the number of appointments is fewer than the number of rules and the per_week number
      role 'tutor'
      admin 'false'

      after(:create) do |tutor|
        tutor.availability_manager = FactoryGirl.build(:availability_manager, per_week: 4, user: tutor)
        tutor.availability_manager.add_weekly_availability('thursday', 4)
        tutor.availability_manager.add_weekly_availability('friday', 4)
        tutor.availability_manager.add_weekly_availability('wednesday', 4)
          [:appointment_thursday, :appointment_friday].each do |appointment|
          tutor.appointments << FactoryGirl.build(appointment, user: tutor)
        end
      end
    end

    factory :tutor_overbooked do
      role 'tutor'
      admin 'false'

      after(:create) do |tutor|
        tutor.availability_manager = FactoryGirl.build(:friday, per_week: 2, user: tutor)
          [:appointment_wednesday, :appointment_thursday, :appointment_friday].each do |appointment|
          tutor.appointments << FactoryGirl.build(appointment, user: tutor)
        end
      end
    end

    factory :tutee_unavailable do
      role 'tutee'
      admin 'false'
      
      after(:create) do |tutee|
        tutee.availability_manager = FactoryGirl.build(:availability_manager, per_week: 3, user: tutee)
        tutee.availability_manager.add_weekly_availability('wednesday', 4)
        tutee.availability_manager.add_weekly_availability('thursday', 4)
        tutee.availability_manager.add_weekly_availability('friday', 4)
        [:appointment_wednesday, :appointment_thursday, :appointment_friday].each do |appointment|
          tutee.appointments << FactoryGirl.build(appointment, user: tutee)
        end
      end
    end

    factory :tutee_available do
      role 'tutee'
      admin 'false'

      after(:create) do |tutee|
        tutee.availability_manager = FactoryGirl.build(:thursday, per_week: 4, user: tutee)
        tutee.availability_manager.add_weekly_availability('thursday', 4)
        tutee.availability_manager.add_weekly_availability('friday', 4)
          [:appointment_thursday, :appointment_friday].each do |appointment|
          tutee.appointments << FactoryGirl.build(appointment, user: tutee)
        end
      end
    end

    factory :tutee_overbooked do
      role 'tutee'
      admin 'false'

      after(:create) do |tutee|
        tutee.availability_manager = FactoryGirl.build(:friday, per_week: 2, user: tutee)
          [:appointment_wednesday, :appointment_thursday, :appointment_friday].each do |appointment|
          tutee.appointments << FactoryGirl.build(appointment, user: tutee)
        end
      end
    end    
  end
end

