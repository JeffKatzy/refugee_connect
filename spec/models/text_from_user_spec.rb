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
	  	@appointment = FactoryGirl.create(:appointment, scheduled_for: Time.current)
	    @text = FactoryGirl.create(:text_from_user)
  	end

		it "should find the user after the text is created" do
			TextFromUser.any_instance.stub(:respond)
			@text.save
			expect(@text.user).to eq @appointment.tutor
	  end
	end

  describe '#attempt_session' do 
  	before do	
			Appointment.any_instance.stub(:remove_availability_occurrence)
			Appointment.any_instance.stub(:start_call)
	  	@appointment = FactoryGirl.create(:appointment, scheduled_for: Time.current)
	    @text = FactoryGirl.build(:text_from_user)
  	end

    it "calls the users with an appointment this hour" do
			@text.save
    end
  end

  describe '#set_user' do
    context "with complete mobile signup" do 
    	before do 
    		@user = FactoryGirl.create(:tutor_available)
    		@text = FactoryGirl.create(:text_from_user)
    	end

    	it "should set the proper user" do 
    		expect(@text.user).to eq @user
    	end
    end

    context "with an incomplete mobile signup" do
      before do 
        @user = FactoryGirl.create(:tutor_available)
        @text_signup = FactoryGirl.create(:text_signup, user: @user)
        @text = FactoryGirl.create(:text_from_user)
      end

      it "sets the user" do
        expect(@text.user).to eq @user
      end
    end
  end

  describe '#request_name' do
    context "when user_initialized" do
      before do 
        @user = FactoryGirl.create(:tutor_available)
        @text_signup = FactoryGirl.create(:text_signup, user: @user, status: 'user_initialized')
        @text = FactoryGirl.create(:text_from_user)
      end

      it "sets the status to user_name_requested" do
        expect(@text_signup.status).to eq 'user_name_requested'
      end
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
        scheduled_for: Time.current + 3.hours,
        user:  FactoryGirl.create(:tutor_available, cell_number: '+12154997415') }

  	context "when text is go" do 
  		let(:body) { 'go' }

	  	it "should attempt session" do 
        @appointment  = FactoryGirl.create(:appointment, 
        scheduled_for: Time.current, 
        status: 'incomplete', 
        tutor: FactoryGirl.create(:tutor_available, cell_number: '+12154997415') ) 
        ReminderText.begin_session

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
    end

    context "when text is 'n' " do
      let(:body) { 'n' }
      let(:status) { 'incomplete' }

      it "it cancels the specific opening" do 
        specific_opening
        text
        expect(specific_opening.reload.status).to eq 'canceled'
      end
    end

    context "when text is 3" do 
      let(:body) { '3' } 
      @appointment  = FactoryGirl.create(:appointment, scheduled_for: Time.current, status: 'complete')

      it "should set the page" do 
        text
        @appointment.reload
        expect(@appointment.finish_page).to eq 3
      end
    end
  end
end
