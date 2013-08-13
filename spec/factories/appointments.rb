# Read about factories at https://github.com/thoughtbot/factory_girl
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
#  scheduled_for :text
#  user_id       :integer
#  began_at      :datetime
#  ended_at      :datetime
#

FactoryGirl.define do
  factory :appointment do
    start_page 10
    finish_page 15
    scheduled_for Time.now + 1.day
    status 'complete'
    
    factory :appointment_this_week do
	    scheduled_for Time.now + 1.day	
    end

    factory :appointment_next_week do
    	scheduled_for Time.now + 1.week
    end

    factory :appointment_wednesday do
    	scheduled_for Chronic.parse('this wednesday 4 pm') - 7.days
    end

    factory :appointment_thursday do
    	scheduled_for Chronic.parse('this thursday 4 pm') - 7.days
    end

   	factory :appointment_friday do
   		scheduled_for Chronic.parse('this friday 4 pm') - 7.days
   	end
  end
end
