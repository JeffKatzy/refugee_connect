# == Schema Information
#
# Table name: appointments
#
#  id            :integer          not null, primary key
#  status        :string(255)
#  start_page    :integer
#  finish_page   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  began_at      :datetime
#  ended_at      :datetime
#  scheduled_for :datetime
#  tutor_id      :integer
#  tutee_id      :integer
#  match_id      :integer
#  lesson_id     :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :appointment do
    scheduled_for (DateTime.new 2013,02,14,12,30,00).end_of_week(:tuesday)

    after(:build) do |appointment|
      appointment.match = FactoryGirl.build(:match) unless appointment.match.present?
      match = appointment.match
      if appointment.tutee.nil?
        appointment.tutee = (appointment.match.tutee || FactoryGirl.create(:tutee_available))
      end

      if appointment.tutor.nil?
        appointment.tutor = (appointment.match.tutor || FactoryGirl.create(:tutor_available))
      end

      appointment.save
      appointment.match.tutor = appointment.tutor 
      appointment.match.tutee = appointment.tutee
      match.save
    end

    factory :appointment_no_tutee do
      scheduled_for DateTime.new 2013,02,14,12,30,00
      status 'complete'
    end      

    factory :apt_five_min do
      scheduled_for DateTime.new 2013,02,14,12,30,00
      status 'incomplete'
    end

    factory :apt_thirty_min do
      scheduled_for DateTime.new 2013,02,14,12,30,00
      status 'incomplete'
    end
    
    factory :appointment_this_week do
	    scheduled_for DateTime.new 2013,02,14,12,30,00 
    end

    factory :appointment_next_week do
    	scheduled_for Time.now + 1.week
    end

    factory :appointment_wednesday do
      time = (DateTime.new 2013,02,14,12,30,00).beginning_of_week.to_date
      scheduled_for time.end_of_week(:thursday)
    end

    factory :appointment_thursday do
      time = (DateTime.new 2013,02,14,12,30,00).beginning_of_week.to_date
    	scheduled_for time.end_of_week(:friday)
    end

   	factory :appointment_friday do
      time = (DateTime.new 2013,02,14,12,30,00).beginning_of_week.to_date
   		scheduled_for time.end_of_week(:saturday)
   	end
  end
end
