# == Schema Information
#
# Table name: text_signups
#
#  id               :integer          not null, primary key
#  status           :string(255)
#  user_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  days_available   :string(255)
#  day_missing_time :string(255)
#

require 'spec_helper'

describe TextSignup do
  describe "register(text)" do 

    ## After users signup, you need to trigger matches, and appointment creation.

    before :each do 
      TextToUser.stub(:deliver) 
      text_signup.navigate_signup(text)
    end

  	let(:text_signup) { FactoryGirl.create :text_signup}

    describe '#request_name' do
      context "when user_initialized" do
        before do 
          @user = FactoryGirl.create(:tutor_available)
          @text_signup = FactoryGirl.create(:text_signup, user: @user, status: 'user_initialized')
          @text = FactoryGirl.create(:text_from_user, incoming_number: @user.cell_number)
        end

        it "sets the status to user_name_requested" do
          expect(@text_signup.status).to eq 'user_name_requested'
        end
      end
    end
  	

  	context "when the user sends the initial text" do
      let(:text) { FactoryGirl.build :text_from_user, body: 'Cool' }
  		
  		it "sets the users cell number" do
  			expect(text_signup.user).to be
  			expect(text_signup.user.cell_number).to eq text.incoming_number
  		end

  		it "sets a random password" do 
  			expect(text_signup.user.password).to be
  		end

      it "sets the users location" do
        expect(text_signup.user.location.city).to eq text.city
        expect(text_signup.user.location.state).to eq text.state
        expect(text_signup.user.location.zip).to eq text.zip
      end

      it "sets the users time zone" do
        expect(text_signup.user.time_zone).to eq 'America/New_York'
      end

      context 'without a found user location' do
        

        context 'with country code of the US' do
          let(:text) { FactoryGirl.build :text_from_user, city: '', state: '', zip: '' }
          it "sets the role and time zone" do 
            expect(text_signup.user.role).to eq 'tutor'
            expect(text_signup.user.time_zone).to eq 'America/New_York'
          end
        end

        context 'with country code of India' do
          let(:text) { FactoryGirl.build :text_from_user, incoming_number: '912154997415', city: '', state: '', zip: '' }

          it "sets the role and time zone" do 
            expect(text_signup.user.role).to eq 'tutee'
            expect(text_signup.user.time_zone).to eq 'New Delhi'
          end
        end
      end 

  		context "without his name" do
        let(:text) { FactoryGirl.build :text_from_user, body: 'Cool' }
		  	it "sets the body to 'Tell us your name' " do
  				expect(text_signup.body).to include('Tell us your name')
		  	end
		  end

		  context "with his name" do
		  	let(:text) { FactoryGirl.create :text_from_user, body: 'Name Jeff' } 

		  	it "sets the users name" do
		  		text_signup.navigate_signup(text)
		  		expect(text_signup.user.name).to eq 'Jeff'
		  	end

		  	it "sets the state to user_with_name" do
		  		text_signup.navigate_signup(text)
		  		expect(text_signup.status).to eq 'class_days_requested'
		  	end
		  end
  	end
  end

  describe 'request_class_days' do

    before :each do 
      TextToUser.stub(:deliver) 
    end

    let(:text_signup) { FactoryGirl.create :text_signup}
    let(:text) { FactoryGirl.build :text_from_user, body: 'Cool' }

  	context "when the state is user_with_name" do
  		it "requests the class days with the bodys content" do
  			text_signup.status = 'user_with_name'
        text_signup.navigate_signup(text)
        expect(text_signup.body).to include("Thanks!  When are you available?")
  		end

      it "sets the status to class_days_set" do
        text_signup.status = 'user_with_name'
        text_signup.navigate_signup(text)
        expect(text_signup.status).to eq 'class_days_requested'
      end
  	end
  end

  describe 'set_days_available' do
    before :each do 
      TextToUser.stub(:deliver) 
    end
    let(:user) { FactoryGirl.create(:tutor_available) }
    let(:text_signup) { FactoryGirl.create :text_signup, user: user}

      context "when the state is class_days_requested" do
        context "and the user enters back the appropriate digits" do
          let(:text) { FactoryGirl.build :text_from_user, body: '123' }

          it "sets the proper days" do
            text_signup.status = 'class_days_requested'
            text_signup.navigate_signup(text)
            expect(text_signup.days_available).to include("123")
          end

          it "sets the status to class_days_set" do
            text_signup.status = 'class_days_requested'
            text_signup.navigate_signup(text)
            expect(text_signup.status).to eq 'class_time_requested'
          end
        end

        context "and the user does not enter back the appropriate digits" do
          let(:text) { FactoryGirl.build :text_from_user, body: 'cool' }

          it "again requests to send the days" do 
            text_signup.status = 'class_days_requested'
            text_signup.navigate_signup(text)
            expect(text_signup.body).to include "Sorry, "
          end
        end
      end
    end

    describe '#attempt_to_find_name' do
      before do 
        TextToUser.stub(:deliver) 
        @user = FactoryGirl.create(:tutor_available)
        @text_signup = FactoryGirl.create(:text_signup)
      end

      context "when user_name_requested and 'Name' not typed" do
        let(:text) { FactoryGirl.create(:text_from_user, body: 'Jeff') }

        it "keeps the state at attempt_to_find_name" do 
          @text_signup.navigate_signup(text)
          expect(@text_signup.status).to eq 'user_name_requested'
        end
      end

      context "when user_name_requested and 'Name' typed" do
        let(:text) { FactoryGirl.create(:text_from_user, body: 'Name Jeff') }

        it "sets the status to user_with_name" do 
          @text_signup.navigate_signup(text)
          expect(@text_signup.status).to eq 'class_days_requested'
        end
      end
    end

  describe '#set_days_available(text)' do

    before do 
      TextToUser.stub(:deliver) 
      @user = FactoryGirl.create(:tutor_available)
      @text_signup = FactoryGirl.create(:text_signup, status: 'class_days_requested', user: @user)
    end

    context "when responding with days and state class_days_requested" do
      let(:text) { FactoryGirl.create(:text_from_user, body: '1 2 3') }

      it "sets the state to class_days_set" do 
        @text_signup.navigate_signup(text)
        expect(@text_signup.status).to eq 'class_time_requested'
      end

      it "sets the days_available to 123" do 
        @text_signup.navigate_signup(text)
        expect(@text_signup.days_available).to eq '123'
      end

      it 'asks the user to submit a time' do
        @text_signup.navigate_signup(text)
        expect(@text_signup.body).to include 'What time on'
      end
    end
  end  

  describe 'request time for day' do
    before :each do 
      TextToUser.stub(:deliver) 
    end

    let(:user) { FactoryGirl.create :tutor_available}
    let(:text_signup) { FactoryGirl.create :text_signup, user: user}
    
  	context "when the user has set class days" do
  		context "and there are days available" do
        let(:text) { FactoryGirl.build :text_from_user, body: '9' }

  			it "requests a time for day" do 
          text_signup.status = 'class_days_set'
          text_signup.days_available = '12'
          text_signup.save
          text_signup.navigate_signup(text)
          expect(text_signup.body).to include "What time on Monday are you available?"
  			end

        it "sets the status to class_time_requested" do 
          text_signup.status = 'class_days_set'
          text_signup.days_available = '12'
          text_signup.save
          text_signup.navigate_signup(text)
          expect(text_signup.status).to include "class_time_requested"
        end
  		end

      context "when the user replies with a time" do
        let(:text) { FactoryGirl.build :text_from_user, body: '1' }

        before :each do 
          @texting_user = FactoryGirl.create(:user)
          text.stub(:user).and_return(@texting_user)
          text_signup.stub(:user).and_return(@texting_user)
          text_signup.status = 'class_time_requested'
          text_signup.days_available = '12'
          text_signup.save
          text_signup.navigate_signup(text)
        end

        it "requests a time for day" do 
          expect(text_signup.body).to include "Great! You now have a class set for Monday."

          expect(text_signup.days_available).to eq '2'
          expect(text_signup.reload.days_available).to eq '2'
        end

        it "creates an opening for the proper day" do
          text.stub(:user).and_return(@texting_user)
          opening = @texting_user.openings.first
          expect(opening.time.strftime("%A")).to eq "Monday"
        end

        it "creates an opening for the proper time" do
          text.stub(:user).and_return(@texting_user)
          opening = @texting_user.openings.first
          expect(opening.time.hour).to eq 8
        end

        context "upon texting another time it" do
          let(:text) { FactoryGirl.build :text_from_user, body: '1' }

          before :each do 
            text_signup.navigate_signup(text)
          end

          it "sets the second time" do 
            expect(text_signup.body).to include "Now signup for twitter"
          end

          it "creates a second opening" do 
            text.stub(:user).and_return(@texting_user)
            expect(@texting_user.openings.count).to eq 2
          end

          it "creates an opening for the proper day" do
            text.stub(:user).and_return(@texting_user)
            opening = @texting_user.openings.last
            expect(opening.time.strftime("%A")).to eq "Tuesday"
          end
        end
      end

  		context "and there are not days available" do
        let(:text) { FactoryGirl.build :text_from_user, body: '1' }

        before :each do 
          @texting_user = FactoryGirl.create(:user)
          text.stub(:user).and_return(@texting_user)
          text_signup.stub(:user).and_return(@texting_user)
          text_signup.status = 'class_days_set'
          text_signup.days_available = ''
          text_signup.save
          text_signup.navigate_signup(text)
        end

  			it "asks for a twitter signup" do
          expect(text_signup.body).to include "Now signup for twitter"
  			end
  		end 
  	end

    describe 'find_twitter_name' do 
      let(:text) { FactoryGirl.build :text_from_user, body: 'twitter jeffkatzy' }

      before :each do 
        @texting_user = FactoryGirl.create(:user)
        text.stub(:user).and_return(@texting_user)
        text_signup.stub(:user).and_return(@texting_user)
        text_signup.status = 'twitter_signup_requested'
        text_signup.save
        text_signup.navigate_signup(text)
      end

      context "when the person enters the correct name" do
        it "sets the status to complete" do
          expect(text_signup.status).to eq 'complete'
        end

        it "texts the user that he is done" do
          expect(text_signup.body).to include 'You are all done'
        end
      end

      context "when the user enters a name that is not found" do 
        it "tells the user that could not find his name" do
          # expect(text_signup.body).to include 'You are all done'
        end
      end
    end
  end

end



  