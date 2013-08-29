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
#

require 'spec_helper'

describe Appointment do
  it 'has a valid factory' do
		FactoryGirl.create(:appointment).should be_valid
	end

	describe '.after(this_week)' do
		before :each do
			@next_month = FactoryGirl.create(:appointment, scheduled_for: Time.now + 1.month )
			@next_month_plus = FactoryGirl.create(:appointment, scheduled_for: Time.now + 2.months )
			@this_week = FactoryGirl.create(:appointment, scheduled_for: Time.now + 1.day)
		end
	
		it "returns appointments after specified time" do
	  	Appointment.after(Time.now + 1.week).should eq [@next_month, @next_month_plus]
		end

		it "does not return users before the time" do
	  	Appointment.after(Time.now + 1.week).should_not include @this_week
		end
	end

	describe '.before(this_week)' do
		before :each do
			@next_month = FactoryGirl.create(:appointment, scheduled_for: Time.now + 1.month )
			@next_month_plus = FactoryGirl.create(:appointment, scheduled_for: Time.now + 2.months )
			@this_week = FactoryGirl.create(:appointment, scheduled_for: Time.now + 1.day)
		end

		it "returns appointments after specified time" do
	  	Appointment.before(Time.now + 2.weeks).should eq [@this_week]
		end

		it "does not return users before the time" do
	  	Appointment.before(Time.now + 2.weeks).should_not include @next_month, @next_month_plus
		end
	end

	describe '#this_hour' do
		before :each do 
			@this_hour = FactoryGirl.create(:appointment, scheduled_for: Time.now + 10.minutes)
			@twenty_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.now + 20.minutes)
			@thirty_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.now + 30.minutes)
			@two_hours = FactoryGirl.create(:appointment, scheduled_for: Time.now + 30.minutes)
		end


		it "should return a list of appointments this hour" do 
			Appointment.this_hour.should eq [@this_hour, @twenty_minutes, @thirty_minutes]
			Appointment.this_hour.should_not include @two_hours
		end
	end

	describe '#current_appointment' do
		before :each do 
			@this_hour = FactoryGirl.create(:appointment, scheduled_for: Time.now + 10.minutes)
			@twenty_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.now + 20.minutes)
			@thirty_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.now + 30.minutes)
			@two_hours = FactoryGirl.create(:appointment, scheduled_for: Time.now + 30.minutes)
		end

		it "should be occurring this hour" do
			Appointment.current_appointment.scheduled_for.hour.should eq Time.now.hour 
		end

		it "should only return one appointment" do
			Appointment.current_appointment.should be_a(Appointment)
		end
	end

	describe ".incomplete" do
		before :each do 
			@complete = FactoryGirl.create(:appointment, status: 'complete')
			@also_complete = FactoryGirl.create(:appointment, status: 'complete')
			@incomplete = FactoryGirl.create(:appointment, status: 'incomplete')
			@also_incomplete = FactoryGirl.create(:appointment, status: 'incomplete')
		end

		it "should return only the incomplete appointments" do
			Appointment.incomplete.should eq [@incomplete, @also_incomplete]
		end
	end

	describe ".next_appointments" do
		before :each do 
			@ten_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.now + 10.minutes, status: 'incomplete')
			@twenty_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.now + 20.minutes, status: 'incomplete')
			@thirty_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.now + 30.minutes, status: 'incomplete')
			@two_hours = FactoryGirl.create(:appointment, scheduled_for: Time.now + 30.minutes, status: 'incomplete')
		end

		it "should return appointments in the order they are scheduled" do
			Appointment.next_appointments.should eq [@ten_minutes, @twenty_minutes, @thirty_minutes, @two_hours]
		end

		it 'should only return incomplete appointments' do
			@ten_minutes.status = 'complete'
			@ten_minutes.save
			@thirty_minutes.status = 'complete'
			@thirty_minutes.save
			Appointment.next_appointments.should eq [@twenty_minutes, @two_hours]
		end
	end

	describe '.next_appointment' do
		before :each do 
			@ten_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.now + 10.minutes, status: 'complete')
			@twenty_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.now + 20.minutes, status: 'incomplete')
			@thirty_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.now + 30.minutes, status: 'incomplete')
			@two_hours = FactoryGirl.create(:appointment, scheduled_for: Time.now + 30.minutes, status: 'incomplete')
		end

		it "should return only the next upcoming, incomplete appointment" do
			Appointment.next_appointment.should eq @twenty_minutes
		end
	end

	describe '#set_status' do
		before :each do 
			@appointment_one = FactoryGirl.create(:appointment, scheduled_for: Time.now - 1.hour, status: 'incomplete', began_at: Time.now.beginning_of_hour, ended_at: Time.now.end_of_hour)
			@appointment_two = FactoryGirl.create(:appointment, scheduled_for: Time.now + 20.minutes, status: 'incomplete', ended_at: nil)
		end

		it "should be complete for scheduled appointments" do
			@appointment_one.set_status
			@appointment_one.status.should eq 'complete'
		end

		it "should remain incomplete for appointments without an end_time" do
			@appointment_two = FactoryGirl.create(:appointment, scheduled_for: Time.now + 20.minutes, status: 'incomplete')
		end
	end
	
	describe '.needs_text' do
		before :each do 
			@appointment_one = FactoryGirl.create(:appointment, scheduled_for: Time.now - 1.hour, began_at: Time.now.beginning_of_hour, ended_at: Time.now.end_of_hour)
			@appointment_two = FactoryGirl.create(:appointment, scheduled_for: Time.now - 20.minutes, ended_at: Time.now.end_of_hour)
			@appointment_three = FactoryGirl.create(:appointment, scheduled_for: Time.now - 40.minutes, ended_at: Time.now.end_of_hour)
			@appointment_one.set_status
			@appointment_two.set_status
			@appointment_three.set_status
		end

		it "should be a complete appointment" do
			Appointment.needs_text.each do |apt|
				apt.status.should eq 'complete'
			end
		end

		it "should have a begin_time and an end_time" do
			Appointment.needs_text.each do |apt|
				apt.begin_time.should_not be_nil
				apt.end_time.should_not be_nil
			end
		end
	end
end
