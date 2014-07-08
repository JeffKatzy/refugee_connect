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

  let(:text) { FactoryGirl.create :text_to_user }

  it 'has a valid factory' do
  	FactoryGirl.create(:reminder_text).should be_valid
  end

  before :each do
    TextToUser.stub(:deliver).and_return(text)
  end

  describe '.confirm_specific_openings' do
    let(:time) {DateTime.new(2013,02,13,00,00,00)}

    before :each do
      ReminderText.delete_all
      SpecificOpening.delete_all
      @eleven_thirty_pm = FactoryGirl.create(:specific_opening, 
        scheduled_for: Time.current.utc.change(hour: 11, min: 30),
        user: FactoryGirl.build(:tutor_available)
        )

      @twelve_thirty_pm = FactoryGirl.create(:specific_opening, 
        scheduled_for: Time.current.utc.change(hour: 12, min: 30),
        user: FactoryGirl.build(:tutor_available)
        )
    end

    context "when it is 9 am" do 
      it "sends confirmation requests for specific openings scheduled for the day" do 
        Timecop.travel(Time.current.utc)
        ReminderText.confirm_specific_openings
        text = ReminderText.first
        expect(text.user).to eq @eleven_thirty_pm.user
        expect(text.category).to eq 'request_confirmation'
        expect(@eleven_thirty_pm.reload.status).to eq 'requested_confirmation'
        expect(ReminderText.count).to eq 2
      end

      it 'does not resend confirmation requests' do
        Timecop.travel(Time.current)
        ReminderText.confirm_specific_openings
        expect(ReminderText.count).to eq 2
        ReminderText.confirm_specific_openings
        expect(ReminderText.count).to eq 2
      end
    end

    context "when a user with a SO no longer exists" do
      before :each do
        @no_user = FactoryGirl.create(:specific_opening, 
          scheduled_for: Time.current,
          user_id: 30009
          )
      end

      it "does not blow up" do
        @no_user.reload
        expect(SpecificOpening.available.today).to include(@no_user)
        expect(ReminderText.confirm_specific_openings).to_not raise_error
      end
    end
  end

  describe 'begin_session' do
  	ReminderText.delete_all
		Appointment.delete_all
    let(:tutor) { FactoryGirl.create(:tutor_available) }
    let(:tutee) { FactoryGirl.create(:tutee_available) }

  	before :each do
			@nine_pm = FactoryGirl.create(:appointment, 
        scheduled_for: Time.current.change(hour: 21, min: 21),
        tutor: tutor, 
        tutee: FactoryGirl.create(:tutee_available, cell_number: '2154997415')
          )

			@ten_pm = FactoryGirl.create(:appointment, 
        scheduled_for: Time.current.change(hour: 22, min: 21),
        tutor: tutor, 
				tutee: tutee
				)

			@eleven_pm = FactoryGirl.create(:appointment, 
        scheduled_for: Time.current.change(hour: 23, min: 21),
				tutor: tutor, 
				tutee: tutee
				)
		end

		context "when it is 9 pm" do 
  		it "sends reminders for appointments in the next hour" do 
  			Timecop.travel(Time.current.change(hour: 21, min: 55))
  			ReminderText.begin_session
  			ReminderText.first.appointment.should eq @nine_pm
  		end

      it "sends different messages to the tutor and tutee" do
        Timecop.travel(Time.current.change(hour: 21, min: 55))
        ReminderText.begin_session
        tutor_text = TextToUser.where(user_id: @nine_pm.tutor.id).first
        tutee_text = TextToUser.where(user_id: @nine_pm.tutee.id).first
        expect(tutor_text.body).to include 'Reply to this text with the word'
        expect(tutee_text.body).to include 'If you would not like'
      end
  	end

  	context "when it is 10 pm" do 
  		it "sends reminders for appointments in the next hour" do 
  			Timecop.travel(Time.current.change(hour: 22, min: 55))
  			ReminderText.begin_session
  			ReminderText.first.appointment.should eq @ten_pm
  		end
  	end

  	context "when it is 11 pm" do 
  		it "sends reminders for appointments scheduled  in the next hour" do 
  			Timecop.travel(Time.current.change(hour: 23, min: 55))
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
      apt_just_before_text = FactoryGirl.create(:appointment, tutor: @user, tutee: @user, scheduled_for: Time.current)
      apt_pm_text = FactoryGirl.create(:appointment, scheduled_for: Time.current + 3.hours, tutor: @user, tutee: @user)
      apts = [apt_pm_text, apt_just_before_text]
      ReminderText.send_reminder_text(apts, "begin_session")
      expect(ReminderText.all.map(&:appointment).uniq).to eq [apts.first, apts.last]
    end

  	context "when apt already had a text of that type" do
  		it "does not resend the text" do 
  			ReminderText.delete_all
        @user = FactoryGirl.create(:user)
  			pm_reminder_text = FactoryGirl.create(:reminder_text, category: 'pm_reminder')
  			just_before_text = FactoryGirl.create(:reminder_text, category: 'just_before')

  			apt_just_before_text = FactoryGirl.create(:appointment, tutor: @user, tutee: @user, scheduled_for: Time.current)
  			apt_pm_text = FactoryGirl.create(:appointment, tutor: @user, tutee: @user, scheduled_for: Time.current)
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
