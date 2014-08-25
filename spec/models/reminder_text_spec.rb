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
    TextToUser.any_instance.stub(:send_text).and_return(true)
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
        user: FactoryGirl.build(:tutee_available)
        )
    end

    context "when it is 9 am" do 
      it "sends confirmation requests for specific openings scheduled for the day" do 
        Timecop.travel(Time.current.utc)
        ReminderText.confirm_specific_openings
        text = Text.first
        expect(text.user).to eq @eleven_thirty_pm.user
        expect(@eleven_thirty_pm.reload.status).to eq 'requested_confirmation'
        expect(Text.count).to eq 2
      end

      it 'does not resend confirmation requests' do
        Timecop.travel(Time.current)
        ReminderText.confirm_specific_openings
        expect(Text.count).to eq 2
        ReminderText.confirm_specific_openings
        expect(Text.count).to eq 2
      end

      it 'sends different messages to the tutor and tutee' do
        Timecop.travel(Time.current)
        ReminderText.confirm_specific_openings
        tutor_text = TextToUser.where(user_id: @eleven_thirty_pm.user.id).first
        tutee_text = TextToUser.where(user_id: @twelve_thirty_pm.user.id).first
        expect(tutor_text.body).to include "Text back 'Y' to confirm or text 'N' to cancel"
        expect(tutee_text.body).to include "If you cannot attend the class"
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

  describe '.missing_apts' do
    let(:time) {DateTime.new(2013,02,13,00,00,00)}

    before :each do
      ReminderText.delete_all
      SpecificOpening.delete_all
      @eleven_thirty_pm = FactoryGirl.create(:specific_opening, 
        scheduled_for: Time.current.utc.change(hour: 11, min: 30),
        user: FactoryGirl.build(:tutor_available),
        status: 'confirmed'
        )

      @twelve_thirty_pm = FactoryGirl.create(:specific_opening, 
        scheduled_for: Time.current.utc.change(hour: 12, min: 30),
        user: FactoryGirl.build(:tutee_available),
        status: 'confirmed' 
        )
    end

    context "when it is 12:31" do
      Timecop.travel(Time.current.utc.change(hour: 12, min: 31))

      it "selects users if there was no match" do
        expect(ReminderText.missing_apts).to eq [@twelve_thirty_pm]
      end

      it "creates the proper text" do
        ReminderText.missing_apts
        expect(Text.first.body).to include 'Sorry!'
        expect(Text.count).to eq 1
      end
    end
  end

  describe 'begin_session' do
		Appointment.delete_all
    Text.delete_all
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
  			Text.first.unit_of_work.should eq @nine_pm
  		end

      it "sends different messages to the tutor and tutee" do
        Timecop.travel(Time.current.change(hour: 21, min: 55))
        ReminderText.begin_session
        tutor_text = TextToUser.where(user_id: @nine_pm.tutor.id).first
        tutee_text = TextToUser.where(user_id: @nine_pm.tutee.id).first
        expect(tutor_text.body).to include 'just use your book and phone'
        expect(tutee_text.body).to include 'You will be receiving a call'
      end
  	end

  	context "when it is 10 pm" do 
  		it "sends reminders for appointments in the next hour" do 
  			Timecop.travel(Time.current.change(hour: 22, min: 55))
  			ReminderText.begin_session
  			Text.first.appointment.should eq @ten_pm
  		end
  	end

  	context "when it is 11 pm" do 
  		it "sends reminders for appointments scheduled  in the next hour" do 
  			Timecop.travel(Time.current.change(hour: 23, min: 55))
  			ReminderText.begin_session
  			Text.first.appointment.should eq @eleven_pm
  		end
  	end
  end
end
