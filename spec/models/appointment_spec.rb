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

require 'spec_helper'

describe Appointment do

	before :each do
		Appointment.any_instance.stub(:send_confirmation_text).and_return(true)
		TextToUser.stub(:deliver).and_return(true)
	end


	describe '#complete' do
		let(:apt) { FactoryGirl.create(:appointment, began_at: Time.current) }

		before do
			apt.complete
		end

		it "should mark the ended at time" do 
			expect(apt.ended_at).to be_present
		end

		it "should mark the appointment as complete" do
			expect(apt.status).to eq 'complete'
		end

		it "should send a text to the tutor" do
			expect(TextToUser.to_receive(:deliver)).to eq 'complete'
		end
	end

	describe 'validations' do
		it "should validate the presences of a tutor" do
			appointment = FactoryGirl.build(:appointment)
			appointment.tutor = nil
			expect(appointment).to_not be_valid
		end

		it "should validate the presences of a tutee" do
			appointment = FactoryGirl.build(:appointment)
			appointment.tutee = nil
			expect(appointment).to_not be_valid
		end

	describe "#find_start_page" do
		let(:apt) {FactoryGirl.create(:apt_five_min, began_at: Time.current, status: 'complete') }

		context "where the appointment is the tutees first" do 
			it "should set the page number to one" do		
				apt.start_page.should eq 1
			end
		end

		context "where the appointment is not the tutees first" do
			it "should set the page number to the most tutee's most recent appointments" do
				apt
				apt.finish_page = 3
				apt.save
				apt_two = FactoryGirl.create(:appointment, scheduled_for: Time.current, status: 'incomplete', tutor_id: apt.tutor.id, tutee_id: apt.tutee.id )
				apt_two.start_page.should eq apt.finish_page				
			end
		end
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

	describe '.this_hour' do
		before :each do 
      Timecop.travel(Time.now.beginning_of_hour)
			@this_hour = FactoryGirl.create(:appointment, scheduled_for: Time.current + 10.minutes)
			@twenty_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.current + 20.minutes)
			@thirty_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.now + 30.minutes)
			@two_hours = FactoryGirl.create(:appointment, scheduled_for: Time.current + 2.hours)
		end


		it "should return a list of appointments this hour" do 
			Appointment.this_hour.should include @this_hour, @twenty_minutes, @thirty_minutes
		end

		it "should not include appointments not in the hour" do
			Appointment.this_hour.should_not include @two_hours
		end
	end

	describe '.next_hour' do
		before :each do 
      Timecop.travel(Time.now.beginning_of_hour)
			@next_hour = FactoryGirl.create(:appointment, scheduled_for: Time.current + 70.minutes)
			@ninety_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.current + 90.minutes)
			@one_hundred_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.now + 100.minutes)
			@this_hour = FactoryGirl.create(:appointment, scheduled_for: Time.current)
			@two_hours = FactoryGirl.create(:appointment, scheduled_for: Time.current + 2.hours)
		end

		it "should return the proper three appointments" do
			expect(Appointment.next_hour).to include(@next_hour, @ninety_minutes, @one_hundred_minutes)
		end

		it "should not include the appointments this hour or in two hours" do
			expect(Appointment.next_hour).to_not include(@this_hour, @two_hours)
		end
	end

	describe '.current' do
		before :each do 
			Timecop.travel(Time.current.beginning_of_hour)
			@this_hour = FactoryGirl.create(:appointment, scheduled_for: Time.current + 10.minutes, status: 'incomplete')
			@twenty_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.current + 20.minutes, status: 'incomplete')
			@thirty_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.current + 30.minutes, status: 'incomplete')
			@forty_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.current + 40.minutes, status: 'incomplete')
		end

		it "should be occurring this hour" do
			Appointment.current.scheduled_for.hour.should eq Time.current.hour 
		end

		it "should only return one appointment" do
			Appointment.current.should be_a(Appointment)
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
			@ten_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.current + 10.minutes, status: 'incomplete')
			@twenty_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.current + 20.minutes, status: 'incomplete')
			@thirty_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.current + 30.minutes, status: 'incomplete')
			@forty_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.current + 40.minutes, status: 'incomplete')
		end

		it "should return appointments in the order they are scheduled" do
			Appointment.next_appointments.should eq [@ten_minutes, @twenty_minutes, @thirty_minutes, @forty_minutes]
		end

		it 'should only return incomplete appointments' do
			@ten_minutes.status = 'complete'
			@ten_minutes.save
			@thirty_minutes.status = 'complete'
			@thirty_minutes.save
			Appointment.next_appointments.should eq [@twenty_minutes, @forty_minutes]
		end
	end

	describe '.next_appointment' do
		before :each do 
			@ten_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.current + 10.minutes, status: 'complete')
			@twenty_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.current + 20.minutes, status: 'incomplete')
			@thirty_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.current + 30.minutes, status: 'incomplete')
			@two_hours = FactoryGirl.create(:appointment, scheduled_for: Time.current + 30.minutes, status: 'incomplete')
		end

		it "should return only the next upcoming, incomplete appointment" do
			Appointment.next_appointment.should eq @twenty_minutes
		end
	end

	describe "most recent" do
		before :each do 
			@ten_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.current - 2.hours + 10.minutes, status: 'complete', began_at: Time.current - 2.hours + 10.minutes)
			@twenty_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.current - 2.hours + 20.minutes, status: 'complete', began_at: Time.current - 2.hours + 20.minutes)
			
			@twenty_five_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.current - 2.hours + 25.minutes, status: 'complete', began_at: Time.current - 2.hours + 25.minutes)
			@thirty_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.current - 2.hours + 30.minutes, status: 'incomplete', began_at: Time.current - 2.hours + 30.minutes)
		end

		it "should display the last complete appointment" do
			Appointment.most_recent.first.should eq @twenty_five_minutes
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
			@appointment_two = FactoryGirl.create(:appointment, scheduled_for: Time.now - 20.minutes, began_at: Time.now.end_of_hour)
			@appointment_three = FactoryGirl.create(:appointment, scheduled_for: Time.now - 40.minutes, ended_at: Time.now.end_of_hour)
			@appointment_one.set_status
			@appointment_two.set_status
			@appointment_three.set_status
		end

		it "should be a complete appointment" do
			Appointment.needs_text.each do |apt|
				apt.should eq @appointment_one
			end
		end
	end

	describe '.batch_for_begin_text' do
		let(:began_at) { nil }
		let(:hour_plus_twenty) { Time.current.utc.beginning_of_hour + 20.minutes }
		let(:hour_plus_ten) { Time.current.utc.beginning_of_hour + 10.minutes }

		before :each do
			Timecop.travel(Time.current.utc.beginning_of_hour + 15.minutes)
			@this_hour = FactoryGirl.create(:appointment, scheduled_for: hour_plus_ten, began_at: began_at, tutor: FactoryGirl.build(:tutor_available), tutee: FactoryGirl.build(:tutee_available))
			@twenty_minutes = FactoryGirl.create(:appointment, scheduled_for: hour_plus_twenty, tutor: FactoryGirl.build(:tutor_available), tutee: FactoryGirl.build(:tutee_available))	
			@two_hours_before = FactoryGirl.create(:appointment, scheduled_for: Time.current.utc.beginning_of_hour - 2.hours)
		end

		it "should not include appointments before this hour" do
			Appointment.batch_for_begin_text.should_not include @two_hours_before
		end

		it "should include appointments this hour, scheduled before the current time" do
			Appointment.batch_for_begin_text.should include @this_hour
		end

		it "should not include appointments after the current time" do
			Appointment.batch_for_begin_text.should_not include @twenty_minutes
		end

		context "when it already started" do
			let(:began_at) { hour_plus_ten }

			it "should not include appointments" do
				Appointment.batch_for_begin_text.should_not include @this_hour
			end
		end
	end

	describe '.batch_for_one_day_from_now' do
		before :each do
			Timecop.travel(Time.current.beginning_of_hour)
			@twenty_four_hrs = FactoryGirl.create(:appointment, scheduled_for: Time.current + 1.day)
			@twenty_four_hrs_plus = FactoryGirl.create(:appointment, scheduled_for: Time.current + 1.day + 10.minutes)	
			@twenty_five_hrs_plus = FactoryGirl.create(:appointment, scheduled_for: Time.current + 25.hours)
		end

		it "should only select appointments within the next 24 to 25 hours" do
			Appointment.batch_for_one_day_from_now.should include @twenty_four_hrs, @twenty_four_hrs_plus
			Appointment.batch_for_one_day_from_now.should_not include @twenty_five_hrs_plus
		end
	end


	describe '.batch_for_just_before' do
		let(:date) { DateTime.new(2020, 2, 3, 4, 5, 6) }

		before :each do
			Timecop.travel(date)
			Appointment.delete_all
			@appointment_one = FactoryGirl.create(:appointment, scheduled_for: date + 80.minutes )
			@appointment_three = FactoryGirl.create(:appointment, scheduled_for: date + 8.hours)
		end

		it "should only select appointments due in the next hour" do
			expect(Appointment.batch_for_just_before).to include @appointment_one
		end
	end

end
