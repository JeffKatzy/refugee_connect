# == Schema Information
#
# Table name: text_from_users
#
#  id              :integer          not null, primary key
#  body            :text
#  time            :datetime
#  user_id         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  incoming_number :string(255)
#  city            :string(255)
#  state           :string(255)
#  zip             :string(255)
#  country         :string(255)
#  appointment_id  :integer
#

require 'spec_helper'

describe TextFromUser do

	describe '#set_user' do 
		before do 
			User.delete_all
			Appointment.any_instance.stub(:start_call)
      CallToUser.any_instance.stub(:start_call)
			Appointment.any_instance.stub(:send_confirmation_text)
      @user = FactoryGirl.create(:user, cell_number: '+12312312336')
	  	@appointment = FactoryGirl.create(:appointment, scheduled_for: Time.current, tutor: @user)
      @text = FactoryGirl.create(:text_from_user, incoming_number: '+12312312336')
  	end

		it "should find the user after the text is created" do
      TextFromUser.any_instance.stub(:twilio_response)
      TextFromUser.any_instance.stub(:register_user)
			@text.save
			expect(@text.user).to eq @appointment.tutor
	  end

    context "with an incomplete mobile signup" do
      before do 
        @user = FactoryGirl.create(:user, cell_number: '+12312312337')
        @text = FactoryGirl.create(:text_from_user, incoming_number: '+12312312337')
      end

      it "sets the user" do
        expect(@text.user).to eq @user
      end
    end
	end

  describe '#attempt_session' do 
  	before do	
      User.delete_all
      @user = FactoryGirl.create(:user, cell_number: '+12312312337')
      @appointment = FactoryGirl.create(:appointment, scheduled_for: Time.current, tutor: @user)
      @text_to_user = FactoryGirl.create(:text_to_user, body: 'go', appointment: @appointment, user: @user)
  	end

    it "calls the users with an appointment this hour" do
      @text = FactoryGirl.create(:text_from_user, body: 'go', incoming_number: '+12312312337')
      #Do not understand how to implement expectation that attempt_session is called
    end
  end

  describe '#twilio_response' do
  	before do 
      User.delete_all
      TextToUser.any_instance.stub(:send_text)
      CallToUser.any_instance.stub(:start_call)
      Appointment.delete_all
  	end

    let(:text) { FactoryGirl.create(:text_from_user, body: body, incoming_number: '+12154997415') }
    let(:specific_opening) { FactoryGirl.create :specific_opening, 
        status: 'available', 
        scheduled_for: Time.current,
        user:  FactoryGirl.create(:tutor_available, cell_number: '+12154997415') }

  	context "when text is go" do 
  		let(:body) { 'go' }

	  	it "should attempt session" do 
        @appointment  = FactoryGirl.create(:appointment, 
        scheduled_for: Time.current, 
        status: 'incomplete', 
        tutor: FactoryGirl.create(:tutor_available, cell_number: '+12154997415') ) 
        ReminderText.begin_session

        #Not sure how to implement
        expect(@appointment).to receive(:start_call)
        text
	  	end
  	end

    context "when text is 'y' " do
      let(:body) { 'y' }
      
      it "it confirms the specific opening" do 
        specific_opening
        text
        expect(specific_opening.reload.status).to eq 'confirmed'
      end

      it "sends back the right text" do
        specific_opening
        text
        expect(Text.last.body).to include("Cool! We'll match you up and text you")
      end
    end

    context "when text is 'n' " do
      let(:body) { 'n' }

      it "it cancels the specific opening" do 
        specific_opening
        text
        expect(specific_opening.reload.status).to eq 'canceled'
      end
    end

    context "when text is 3" do 
      it "should set the page" do
        @user = FactoryGirl.create(:user, cell_number: '+12312312334', role: 'tutor') 
        appointment = FactoryGirl.create(:appointment, scheduled_for: Time.current, status: 'complete', tutor: @user)
        text = FactoryGirl.create(:text_from_user, incoming_number: '+12312312334', body: '3')
        expect(appointment.reload.finish_page).to eq 3
      end
    end
  end

  describe 'attempt_session' do
    before do 
      User.delete_all
      TextToUser.any_instance.stub(:send_text)
      CallToUser.any_instance.stub(:start_call)
      Appointment.delete_all
      text_to_user
    end

    let(:user) { FactoryGirl.create(:user) }
    let(:text_to_user) { FactoryGirl.create(:text_to_user, user: user, appointment: appointment) }

    
    let(:text_from_user) { FactoryGirl.create(:text_from_user, body: body, appointment: appointment, user: user) }

    context "when there is an appointment this hour" do 
      let(:appointment) { FactoryGirl.create(:appointment, tutor: user, scheduled_for: time) }
      let(:time) { Time.current }

      it "should attempt session" do 
        expect(appointment).to receive(:start_call)
        text_from_user.attempt_session
      end    
    end

    context "when there is not an appointment this hour" do
      let(:appointment) { FactoryGirl.create(:appointment, tutor: user, scheduled_for: time) }
      let(:time) { Time.current + 70.minutes }

      it "should send a text saying there is no appointment this hour" do
        text_from_user.attempt_session
        expect(TextToUser.last.body).to include("No sessions for this hour.")
      end
    end 
  end
end
