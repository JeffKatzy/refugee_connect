# == Schema Information
#
# Table name: reminder_texts
#
#  id             :integer          not null, primary key
#  appointment_id :integer
#  time           :datetime
#  user_id        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  category       :string(255)
#

require 'spec_helper'

describe ReminderText do
  it 'has a valid factory' do
  	FactoryGirl.create(:reminder_text).should be_valid
  end

  describe "apts_in_one_day" do
  	let(:time) {DateTime.new(2013,02,13,00,00,00)}
  	before :each do
  		ReminderText.delete_all
  		Appointment.delete_all
			@nine_pm = FactoryGirl.create(:appointment, scheduled_for: time + 1.day + 21.hours,
				tutor: FactoryGirl.build(:tutor_available), 
				tutee: FactoryGirl.build(:tutee_available)
				)

			@ten_pm = FactoryGirl.create(:appointment, 
				scheduled_for: time + 1.day + 22.hours, tutor: FactoryGirl.build(:tutor_available), 
				tutee: FactoryGirl.build(:tutee_available)
				)

			@eleven_pm = FactoryGirl.create(:appointment, 
				scheduled_for: time + 1.day + 23.hours, 
				tutor: FactoryGirl.build(:tutor_available), 
				tutee: FactoryGirl.build(:tutee_available)
				)
		end

		context "when it is 9 pm" do 
  		it "sends reminders for appointments scheduled at 9 pm" do 
  			Timecop.travel(time + 21.hours)
  			ReminderText.apts_in_one_day
        text = ReminderText.first
  			text.appointment.should eq @nine_pm
        expect(text.category).to eq 'pm_reminder'
  			expect(ReminderText.count).to eq 1
  		end
  	end

		context "when it is 10 pm" do 
  		it "sends reminders for appointments scheduled at 10 pm" do 
  			Timecop.travel(time + 22.hours)
  			ReminderText.apts_in_one_day
        text = ReminderText.first
        text.appointment.should eq @ten_pm
        expect(text.category).to eq 'pm_reminder'
  			expect(ReminderText.count).to eq 1
  		end
  	end

  	context "when it is 11 pm" do 
  		it "sends reminders for appointments scheduled at 11 pm" do 
  			Timecop.travel(time + 23.hours)
  			ReminderText.apts_in_one_day
        text = ReminderText.first
        text.appointment.should eq @eleven_pm
        expect(text.category).to eq 'pm_reminder'
  			expect(ReminderText.count).to eq 1
  		end
  	end
	end

	describe "just_before_reminder" do
		ReminderText.delete_all
		Appointment.delete_all
  	let(:time) {DateTime.new(2013,02,13,00,00,00)}
  	before :each do
			@nine_pm = FactoryGirl.create(:appointment, scheduled_for: time + 21.hours + 20.minutes,
				tutor: FactoryGirl.build(:tutor_available), 
				tutee: FactoryGirl.build(:tutee_available)
				)

			@ten_pm = FactoryGirl.create(:appointment, 
				scheduled_for: time + 22.hours + 30.minutes, tutor: FactoryGirl.build(:tutor_available), 
				tutee: FactoryGirl.build(:tutee_available)
				)

			@eleven_pm = FactoryGirl.create(:appointment, 
				scheduled_for: time + 23.hours + 40.minutes, 
				tutor: FactoryGirl.build(:tutor_available), 
				tutee: FactoryGirl.build(:tutee_available)
				)
		end

		context "when it is 9 pm" do 
  		it "sends reminders for appointments in the next hour" do 
  			Timecop.travel(time + 21.hours)
  			ReminderText.just_before_apts
        text = ReminderText.first
        text.appointment.should eq @ten_pm
        expect(text.category).to eq "just_before_reminder"
  		end
  	end

  	context "when it is 10 pm" do 
  		it "sends reminders for appointments in the next hour" do 
  			Timecop.travel(time + 22.hours)
  			ReminderText.just_before_apts
        text = ReminderText.first
  			text.appointment.should eq @eleven_pm
        expect(text.category).to eq "just_before_reminder"
  		end
  	end

  	context "when it is 8 pm" do 
  		it "sends reminders for appointments scheduled  in the next hour" do 
  			Timecop.travel(time + 20.hours)
  			ReminderText.just_before_apts
        text = ReminderText.first
        text.appointment.should eq @nine_pm
        expect(text.category).to eq "just_before_reminder"
  		end
  	end
  end

  describe 'begin_session' do
  	ReminderText.delete_all
		Appointment.delete_all
  	let(:time) {DateTime.new(2013,02,13,00,00,00)}
  	before :each do
			@nine_pm = FactoryGirl.create(:appointment, scheduled_for: time + 21.hours + 20.minutes,
				tutor: FactoryGirl.build(:tutor_available), 
				tutee: FactoryGirl.build(:tutee_available)
				)

			@ten_pm = FactoryGirl.create(:appointment, 
				scheduled_for: time + 22.hours + 30.minutes, tutor: FactoryGirl.build(:tutor_available), 
				tutee: FactoryGirl.build(:tutee_available)
				)

			@eleven_pm = FactoryGirl.create(:appointment, 
				scheduled_for: time + 23.hours + 40.minutes, 
				tutor: FactoryGirl.build(:tutor_available), 
				tutee: FactoryGirl.build(:tutee_available)
				)
		end

		context "when it is 9 pm" do 
  		it "sends reminders for appointments in the next hour" do 
  			Timecop.travel(time + 21.hours)
  			ReminderText.begin_session
  			ReminderText.first.appointment.should eq @nine_pm
  		end
  	end

  	context "when it is 10 pm" do 
  		it "sends reminders for appointments in the next hour" do 
  			Timecop.travel(time + 22.hours)
  			ReminderText.begin_session
  			ReminderText.first.appointment.should eq @ten_pm
  		end
  	end

  	context "when it is 11 pm" do 
  		it "sends reminders for appointments scheduled  in the next hour" do 
  			Timecop.travel(time + 23.hours)
  			ReminderText.begin_session
  			ReminderText.first.appointment.should eq @eleven_pm
  		end
  	end
  end

  describe "send_reminder_text" do
    before :each do 
      ReminderText.delete_all
      TextToUser.any_instance.stub(:send_text)
    end

    it 'marks the reminder text with the proper appointments' do
      @user = FactoryGirl.create(:user)
      apt_just_before_text = FactoryGirl.create(:appointment, tutor: @user, tutee: @user)
      apt_pm_text = FactoryGirl.create(:appointment, scheduled_for: Time.current + 3.hours, tutor: @user, tutee: @user)
      apts = [apt_pm_text, apt_just_before_text]
      ReminderText.send_reminder_text(apts, "begin_session")
      expect(ReminderText.all.map(&:appointment).uniq).to eq [apts.first, apts.last]
    end

  	context "when apt already had a text of that type" do
  		it "does not resend the text" do 
  			ReminderText.delete_all
  			pm_reminder_text = FactoryGirl.create(:reminder_text, category: 'pm_reminder')
  			just_before_text = FactoryGirl.create(:reminder_text, category: 'just_before')

  			apt_just_before_text = FactoryGirl.create(:appointment)
  			apt_pm_text = FactoryGirl.create(:appointment)
        apts = [apt_pm_text, apt_just_before_text]

  			apt_pm_text.reminder_texts << pm_reminder_text
  			apt_just_before_text.reminder_texts << just_before_text
  			
  			ReminderText.send_reminder_text(apts, "pm_reminder")
  			expect(ReminderText.all.count).to eq 3
  			expect(ReminderText.last.appointment).to eq apt_just_before_text
  		end
  	end
  end
end
