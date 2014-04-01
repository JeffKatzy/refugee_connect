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
#

require 'spec_helper'

describe TextFromUser do

	describe '#set_user' do 
		before do 
			User.delete_all
			Appointment.any_instance.stub(:remove_availability_occurrence)
			Appointment.any_instance.stub(:start_call)
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
  	before do 
  		@user = FactoryGirl.create(:tutor_available)
  		@text = FactoryGirl.create(:text_from_user)
  	end

  	it "should set the proper user" do 
  		expect(@text.user).to eq @user
  	end
  end

  describe '#twilio_response' do
  	before do 
      @appointment = FactoryGirl.create(:appointment, scheduled_for: Time.current)
  		@text = FactoryGirl.create(:text_from_user, body: body)
  	end

  	context "when text is go" do 
  		let(:body) { 'go' }

	  	it "should attempt session" do 
	  		expect(@text).to receive(:attempt_session)
	  	end
  	end
  end
end
