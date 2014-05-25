# == Schema Information
#
# Table name: users
#
#  id               :integer          not null, primary key
#  email            :string(255)
#  password_digest  :string(255)
#  cell_number      :string(255)
#  role             :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  admin            :boolean
#  name             :string(255)
#  active           :boolean
#  per_week         :integer
#  uid              :string(255)
#  oauth_token      :string(255)
#  oauth_expires_at :datetime
#  image            :string(255)
#  time_zone        :string(255)
#  twitter_handle   :string(255)
#

require 'faker'

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password 'password'
    name 'jeffers'
    cell_number Faker::PhoneNumber.cell_phone
    time_zone 'New Delhi'

    factory :tutor_unavailable do
      role 'tutor'
      admin 'active'
      time_zone 'America/New_York'
      cell_number Faker::PhoneNumber.cell_phone
      
      after(:create) do |tutor|
        time = DateTime.new 2013,02,14,12,30,00
        [ FactoryGirl.build(:appointment_wednesday), FactoryGirl.build(:appointment_thursday), FactoryGirl.build(:appointment_friday)].each do |apt|
          tutor.appointments << apt
          apt.save
        end
      end
    end

    factory :tutor_available do
      #tutor is available: the number of appointments is fewer than the number of rules and the per_week number
      role 'tutor'
      admin 'false'
      time_zone 'America/New_York'
      cell_number Faker::PhoneNumber.cell_phone
      per_week 5
    end

    factory :tutee_unavailable do
      role 'tutee'
      admin 'false'
      time_zone "New Delhi"
      cell_number '+91 97960 97962'
      per_week '3'
        
      after(:create) do |tutee|
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
    end
  end
end

