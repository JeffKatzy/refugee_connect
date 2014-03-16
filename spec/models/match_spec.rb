# == Schema Information
#
# Table name: matches
#
#  id         :integer          not null, primary key
#  tutor_id   :integer
#  tutee_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  match_time :datetime
#  available  :boolean
#

require 'spec_helper'

describe Match do
	describe '.create' do
		before :each do
			@match = FactoryGirl.create(:match, match_time: Time.now + 1.month )
		end 

		it "should mark the match as available" do
			expect(@match.available).to eq true
		end
	end

	context "when either user is not available" do
		let(:first_match) { FactoryGirl.create(:match) }
		let(:apt) { first_match.convert_to_apt }
		let(:second_match) { FactoryGirl.build(:match, tutor: first_match.tutor) }
		let(:third_match) { FactoryGirl.build(:match, tutee: first_match.tutee) }
		

		it "should not invalidate when a tutor does not already have an appointment then" do
			apt.save
			expect(first_match.valid?).to be_true
		end

		it "should invalidate when a tutor already has an appointment then" do
			apt.save
			second_match
			expect(second_match.valid?).to be_false
			expect(second_match.errors.messages[:base].pop).to eq "A tutor is already scheduled at that time."
		end

		it "should invalidate when a tutee already has an appointment then" do
			apt.save
			second_match
			expect(third_match.valid?).to be_false
			expect(third_match.errors.messages[:base].pop).to eq "A tutee is already scheduled at that time."
		end
	end

	describe '#already_a_match' do
		before :each do
			Match.delete_all
      time = DateTime.new(2013,02,14,12,30,00)
      Timecop.travel(time.beginning_of_week)
      @tutor = FactoryGirl.create(:tutor_available)
      @tutee = FactoryGirl.create(:tutee_available)
      Match.match_create(@tutor, @tutee, Time.current.end_of_week)
    end

		it "should return true if there is already a match for a given time" do
			expect(Match.already_a_match(@tutor, @tutee, Time.parse("2013-02-15 12:30:00 UTC"))).to eq true
		end

		it "should return false if there is not already a match for a given time" do
			expect(Match.already_a_match(@tutor, @tutee, Time.parse("2012-02-20 12:30:00 UTC"))).to eq false
		end
	end

	describe '.after(this_week)' do
		before :each do
			@next_month = FactoryGirl.create(:match, match_time: Time.now + 1.month )
			@next_month_plus = FactoryGirl.create(:match, match_time: Time.now + 2.months )
			@this_week = FactoryGirl.create(:match, match_time: Time.now + 1.day)
		end
	
		it "returns appointments after specified time" do
	  	Match.after(Time.now + 1.week).should eq [@next_month, @next_month_plus]
		end

		it "does not return users before the time" do
	  	Match.after(Time.now + 1.week).should_not include @this_week
		end
	end

	describe ".unavailable" do
		before :each do 
			@available = FactoryGirl.create(:match)
			@unavailable = FactoryGirl.create(:match)
			@available_one = FactoryGirl.create(:match)
			@unavailable_one = FactoryGirl.create(:match)
		end

		it "should return only the incomplete appointments" do
			@unavailable.available = false
			@unavailable.save
			@unavailable_one.available = false
			@unavailable_one.save
			Match.available.should eq [@available, @available_one]
		end
	end

	describe '.convert_to_apt' do
		before :each do
			@match = FactoryGirl.create(:match)
			@match.convert_to_apt
		end

		it "should return an appointment with the same time" do
			expect(@match.appointment.scheduled_for).to eq @match.match_time
		end

		it "should mark the match as unavailable" do
			expect(@match.available).to eq false
		end
	end

	describe '#available_users' do 
		let(:match) { FactoryGirl.create(:match) }
		let(:match_unavailable_tutor) { FactoryGirl.create(:match, tutor: FactoryGirl.create(:tutor_unavailable, per_week: 4), tutee: FactoryGirl.create(:tutee_available)) }

		before(:each) do
			time = DateTime.new(2013,02,14,12,30,00)
			Timecop.travel(time.beginning_of_week)
			Appointment.any_instance.stub(:make_match_unavailable).and_return(true)
			Appointment.any_instance.stub(:send_confirmation_text).and_return(true)
		end

		it "should return true if both users want more appointments" do
			expect(match.available_users).to be_true
		end

		it "should return false if one or more users do not want more appointments" do
			tutor = match_unavailable_tutor.tutor
			tutor.per_week = 3
			tutor.save
			expect(match_unavailable_tutor.available_users).to be_false
		end
	end

	describe '#available_matches_until(time)' do
		let(:match_unavailable_tutor) { FactoryGirl.create(:match, tutor: FactoryGirl.create(:tutor_unavailable, per_week: 4), 
			tutee: FactoryGirl.create(:tutee_available)) }

		it "should only return matches that are not appointments" do
			time = DateTime.new 2013,02,14,12,30,00
			Timecop.travel(time.beginning_of_week)
			Appointment.any_instance.stub(:send_confirmation_text)
			@match_to_apt = FactoryGirl.create(:match)
			@match_to_apt.convert_to_apt
			tutor = @match_to_apt.tutor
			@match = FactoryGirl.create(:match, match_time: @match_to_apt.match_time + 3.hours, tutor: tutor)
			matches = tutor.reload.matches
			expect(matches.available_until(time.end_of_week)).to_not include(@match_to_apt)
			expect(matches.available_until(time.end_of_week)).to include(@match)
		end

		it "should only return matches where both users are available" do 
			time = DateTime.new 2013,02,14,12,30,00
			Timecop.travel(time.beginning_of_week)
			Appointment.any_instance.stub(:send_confirmation_text)
			Appointment.any_instance.stub(:make_match_unavailable)

			tutor = match_unavailable_tutor.tutor
			tutor.per_week = 3
			tutor.save

			tutee = match_unavailable_tutor.tutee

			@match = FactoryGirl.create(:match, tutee: tutee)
			
			matches = tutor.reload.matches
			tutee_matches = tutee.reload.matches
			
			expect(matches.available_until(time.end_of_week)).to_not include(match_unavailable_tutor)
			expect(tutee_matches.available_until(time.end_of_week)).to include(@match)
		end
	end

	describe '.before(this_week)' do
		before :each do
			@next_month = FactoryGirl.create(:match, match_time: Time.now + 1.month )
			@next_month_plus = FactoryGirl.create(:match, match_time: Time.now + 2.months )
			@this_week = FactoryGirl.create(:match, match_time: Time.now + 1.day)
		end

		it "returns appointments after specified time" do
	  	Match.before(Time.now + 2.weeks).should eq [@this_week]
		end

		it "does not return users before the time" do
	  	Match.before(Time.now + 2.weeks).should_not include @next_month, @next_month_plus
		end
	end

	describe '.match_create(first_user, second_user, datetime)' do
		before :each do
      time = DateTime.new(2013,02,14,12,30,00)
      Timecop.travel(time.beginning_of_week)
      @tutor = FactoryGirl.create(:tutor_available)
      @tutee = FactoryGirl.create(:tutee_available)
      @tutee_unavailable = FactoryGirl.create(:tutee_unavailable)
      Match.delete_all
    end

		it "should produce match objects of the intersecting times and the users" do
			Match.match_create(@tutor, @tutee, Time.current.end_of_week)
			Match.all.map(&:match_time).to_s.should eq "[Wed, 13 Feb 2013 12:30:00 UTC +00:00, Thu, 14 Feb 2013 12:30:00 UTC +00:00, Fri, 15 Feb 2013 12:30:00 UTC +00:00]"
		end
		#this is the already_a_match method, and should probably occur with validation
		it "should not create a match if there is already a match with the same user at that time" do 
			Match.match_create(@tutor, @tutee, Time.current.end_of_week)
			Match.all.map(&:match_time).to_s.should eq "[Wed, 13 Feb 2013 12:30:00 UTC +00:00, Thu, 14 Feb 2013 12:30:00 UTC +00:00, Fri, 15 Feb 2013 12:30:00 UTC +00:00]"
			Match.match_create(@tutor, @tutee, Time.current.end_of_week)
			Match.all.map(&:match_time).to_s.should eq "[Wed, 13 Feb 2013 12:30:00 UTC +00:00, Thu, 14 Feb 2013 12:30:00 UTC +00:00, Fri, 15 Feb 2013 12:30:00 UTC +00:00]"
		end

		it "should not create the match if it is invalid" do
			Match.delete_all
			@tutee_unavailable.per_week = 0
			@tutee_unavailable.save
			match = Match.match_create(@tutor, @tutee_unavailable, Time.current.end_of_week)
			expect(Match.all.count).to eq 0
		end
	end

	describe '.build_all_matches_for(user,datetime)' do
		before :each do
			User.delete_all
      time = DateTime.new(2013,02,14,12,30,00)
      Timecop.travel(time.beginning_of_week)
      @simran = FactoryGirl.create(:tutor_available)
      @nitika = FactoryGirl.create(:tutee_available)
      @sharad = FactoryGirl.create(:tutee_unavailable)
    end

    context "when two users are matches" do 
    	it "should have the same matches" do
    		Match.build_all_matches_for(@simran, Time.current.end_of_week)
    		Match.build_all_matches_for(@nitika, Time.current.end_of_week)
    		expect(@simran.reload.matches).to eq @nitika.reload.matches
    	end

    	it "should have not create new matches after the second user" do
    		Match.build_all_matches_for(@simran, Time.current.end_of_week)
    		init_matches = @simran.reload.matches
    		Match.build_all_matches_for(@nitika, Time.current.end_of_week)
    		expect(@simran.reload.matches).to eq init_matches
    	end
    end

	  context "when its a new user without previous appointments or matches" do 
	    it "should return a hash of users with the values being only times the user has" do
	      Match.build_all_matches_for(@simran, Time.current.end_of_week)
	      @simran.reload.matches.map(&:match_time).to_s.should eq "[Wed, 13 Feb 2013 12:30:00 UTC +00:00, Thu, 14 Feb 2013 12:30:00 UTC +00:00, Fri, 15 Feb 2013 12:30:00 UTC +00:00]"
	    end

	    it "should only return for users who are available" do
	    	@shar = FactoryGirl.create(:tutee_unavailable)
	      Match.build_all_matches_for(@shar, Time.current - 1.day).should eq nil
	    end
	  end

	  context "when a user had past appointments" do 
	    it "should return previous appointment partners ordered by most recent" do
	    	@vishnu = FactoryGirl.create(:tutee_available)
	    	time = DateTime.new(2013,02,14,12,30,00)
	    	Timecop.travel(time.beginning_of_week)
	    	Match.build_all_matches_for(@simran, Time.current.end_of_week)
	    	@simran.appointments = [ FactoryGirl.build(:appointment_wednesday, tutor: @simran, tutee: @nitika), FactoryGirl.build(:appointment_thursday, tutor: @simran, tutee: @vishnu)]
	    	init_matches = @simran.reload.matches.count
	    	
	    	Timecop.travel(time.beginning_of_week + 7.days)
	    	@ashu = FactoryGirl.create(:tutee_available)
	    	Match.build_all_matches_for(@simran, Time.current.end_of_week)
	    	@simran.reload.matches.count.should be > init_matches
	    	@simran.reload.matches.after(Time.current.utc.beginning_of_week).before(Time.current.utc.end_of_week).map(&:tutee).uniq.should include @nitika
	    	@simran.reload.matches.after(Time.current.utc.beginning_of_week).before(Time.current.utc.end_of_week).map(&:tutee).uniq.include?(@ashu).should be_false
	    end
	  end

	  context "when a user did not have previous appointments but had matches" do 
	  	it "should preference previous matches" do
	  		@vishnu = FactoryGirl.create(:tutee_available)
	  		time = DateTime.new(2013,02,14,12,30,00)
	    	Timecop.travel(time.beginning_of_week)
	    	Match.build_all_matches_for(@simran, Time.current.end_of_week)
	    	init_matches = @simran.matches.count

	    	Timecop.travel(time.beginning_of_week + 7.days)
	  		@prithi = FactoryGirl.create(:tutee_available)
	  		@shital = FactoryGirl.create(:tutee_available)
	  		@vitaly = FactoryGirl.create(:tutee_available)
	  		@simran.reload
	  		Match.build_all_matches_for(@simran, Time.current.end_of_week)
	    	@simran.reload.matches.count.should be > init_matches
	    	@simran.reload.matches.after(Time.current.utc.beginning_of_week).before(Time.current.utc.end_of_week).map(&:tutee).uniq.should match_array @simran.match_partners
	    	@simran.reload.matches.after(Time.current.utc.beginning_of_week).before(Time.current.utc.end_of_week).map(&:tutee).uniq.include?(@prithi || @shital || @vitaly).should be_false
	    end
	  end
	end
end
