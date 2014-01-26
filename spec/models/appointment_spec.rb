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
#

require 'spec_helper'

describe Appointment do

	before :each do
		Appointment.any_instance.stub(:send_confirmation_text).and_return(true)
	end

	describe ".create" do
		let(:apt) { FactoryGirl.create(:appointment) }
		it 'should be marked as incomplete' do
			expect(apt.status).to eq 'incomplete'
		end
		
		it "should remove the occurrence with the correct parameter" do
			tutor = FactoryGirl.create(:tutor_available)
			tutee = FactoryGirl.create(:tutee_available)
			time = tutee.availability_manager.schedule.occurrences(Time.current.end_of_week + 7.days).first
			apt = FactoryGirl.create(:appointment, tutor: tutor, tutee: tutee, scheduled_for: time)
			tutee.availability_manager.schedule.occurrences(Time.now.end_of_week + 7.days).first.should_not eq time
		end
	end

	describe 'validations' do
		context "when users are not available" do
			before(:each) do
				time = DateTime.new(2013,02,14,12,30,00)
				Timecop.travel(time.beginning_of_week)
				Appointment.any_instance.stub(:make_match_unavailable).and_return(true)
				Appointment.any_instance.stub(:send_confirmation_text).and_return(true)
			end

			let(:appointment) { FactoryGirl.build(:appointment) }
			let(:apt_unavailable_tutor) { FactoryGirl.build(:appointment, tutor: FactoryGirl.create(:tutor_unavailable), 
					tutee: FactoryGirl.create(:tutee_available)) }

			it "should not save unless both want more appointments" do
				expect(apt_unavailable_tutor).to_not be_valid
			end

			it "should not invalidate if both want more appointments" do
				expect(appointment).to be_valid
			end
		end

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
				apt.finish_page = 3
				apt.save
				apt_two = FactoryGirl.create(:appointment, scheduled_for: Time.current, status: 'incomplete', tutor_id: apt.tutor.id, tutee_id: apt.tutee.id )
				apt.save
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

	describe '.batch_for_this_hour' do
		before :each do
			Timecop.travel(Time.current.beginning_of_hour + 7.minutes)
			@this_hour = FactoryGirl.create(:appointment, scheduled_for: Time.current + 10.minutes, tutor: FactoryGirl.build(:tutor_available), tutee: FactoryGirl.build(:tutee_available))
			@twenty_minutes = FactoryGirl.create(:appointment, scheduled_for: Time.current + 20.minutes, tutor: FactoryGirl.build(:tutor_available), tutee: FactoryGirl.build(:tutee_available))	
			@two_hours = FactoryGirl.create(:appointment, scheduled_for: Time.current + 2.hours)
		end

		it "should only select appointments from this hour" do
			Appointment.batch_for_this_hour.should include @this_hour, @twenty_minutes
			# Appointment.fully_assigned.after(Time.now.beginning_of_hour).before(Time.now.end_of_hour).should eq [@appointment_one, @appointment_two]
		end

		it "should include appointments at the beginning of the hour" do
			@appointment_four = FactoryGirl.create(:appointment, scheduled_for: Time.current.beginning_of_hour, tutor: FactoryGirl.build(:tutor_available), tutee: FactoryGirl.build(:tutee_available))
			Appointment.batch_for_this_hour.should include @this_hour, @twenty_minutes, @appointment_four
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


	describe '.batch_for_just_before_reminder_text' do
		let(:date) { DateTime.new(2020, 2, 3, 4, 5, 6) }
		before :each do
			@appointment_one = FactoryGirl.create(:appointment, scheduled_for: date + 20.minutes )
			@appointment_two = FactoryGirl.create(:appointment, scheduled_for: date + 10.minutes )
			@appointment_three = FactoryGirl.create(:appointment, scheduled_for: date.change(hour: 8))
		end

		it "should only select appointments due in forty minutes" do
			Appointment.fully_assigned.
      where("begin_time between (?) and (?)", Time.now.utc, (Time.now.utc + 40.minutes))
		end
	end

	describe '.batch_create' do
		before :each do 
			Appointment.delete_all
			@match_one = FactoryGirl.create(:match)
			@match_two = FactoryGirl.create(:match)
			@match_three = FactoryGirl.create(:match)
		end

		it "should have matches belong to the appointment" do
			@matches = [ @match_one, @match_two, @match_three ]
			Appointment.batch_create(@matches)

			expect(@match_one.appointment).to be_present
			expect(@match_two.appointment).to be_present
			expect(@match_three.appointment).to be_present
		end

		it "should convert an array of matches into appointments" do
			@matches = [ @match_one, @match_two, @match_three ]
			Appointment.batch_create(@matches)
			
			@first_appointment = @match_one.appointment
			@second_appointment = @match_two.appointment
			@last_appointment = @match_three.appointment

			expect(@first_appointment.scheduled_for).to eq @match_one.match_time
			expect(@second_appointment.scheduled_for).to eq @match_two.match_time
			expect(@last_appointment.scheduled_for).to eq @match_three.match_time
		end
	end

	describe '.auto_batch_create' do
		let(:user) { FactoryGirl.create(:user) }
		let(:tutor_available) { FactoryGirl.create(:tutor_available) }
		let(:tutee_available) { FactoryGirl.create(:tutee_available) }
		let(:time) {DateTime.new(2013,02,14,12,30,00)}

		it "should build matches for a user if they do not have matches for the specified time" do
			Match.delete_all
			Appointment.delete_all
			Timecop.travel(time.beginning_of_week)
			Match.should_receive(:build_all_matches_for).twice
			Appointment.auto_batch_create(time: time.end_of_week, users: [tutor_available])
		end

		it "should preference matches where the match is an apt partner" do
			Match.delete_all
			Appointment.delete_all
			Timecop.travel(time.beginning_of_week)
			Appointment.any_instance.stub(:send_confirmation_text).and_return(true)

			match = FactoryGirl.create(:match, tutee: tutee_available, tutor: tutor_available)
			match.convert_to_apt
			match_other_tutor = FactoryGirl.create(:match, tutor: FactoryGirl.create(:tutor_available), tutee: tutee_available)
			match_same_apt_tutor = FactoryGirl.create(:match, tutor: tutor_available, tutee: tutee_available)
			match_different_tutor = FactoryGirl.create(:match, tutor: FactoryGirl.create(:tutor_available), tutee: tutee_available)
			match_another_different_tutor = FactoryGirl.create(:match, tutor: FactoryGirl.create(:tutor_available), tutee: tutee_available)
			Appointment.auto_batch_create(users: [tutee_available], time: time.end_of_week)
			expect(tutee_available.appointments.order(:created_at).last.match).to eq match_same_apt_tutor
		end

		# it "should handle invalid appointments" do
		# 	Match.delete_all
		# 	Appointment.delete_all
		# 	Timecop.travel(time.beginning_of_week)
		# 	Match.should_receive(:build_all_matches_for).twice
		# 	time = DateTime.new(2013,02,14,12,30,00)
		# 	Appointment.auto_batch_create(time: time.end_of_week, users: [tutor_available])
		# end
	end


end
