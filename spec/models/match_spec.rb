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
#

require 'spec_helper'

describe Match do

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

	describe '.this_week' do
		before :each do 
			@next_month = FactoryGirl.create(:match, match_time: Time.now + 1.month )
			@next_month_plus = FactoryGirl.create(:match, match_time: Time.now + 2.months )
			@this_week = FactoryGirl.create(:match, match_time: Time.now + 1.day)
		end

		it "returns appointments for this week" do
	  	Match.this_week.should eq [@this_week]
		end

		it "does not return users not for this week" do
	  	Match.this_week.should_not include @next_month, @next_month_plus
		end
	end

	describe '.match_create(first_user, second_user, datetime)' do
		before :each do
      time = DateTime.new(2013,02,14,12,30,00)
      Timecop.travel(time.beginning_of_week)
      @tutor = FactoryGirl.create(:tutor_available)
      @tutee = FactoryGirl.create(:tutee_available)
      Match.delete_all
    end

		it "should produce match objects of the intersecting times and the users" do
			Match.match_create(@tutor, @tutee, Time.current.end_of_week)
			Match.all.map(&:match_time).to_s.should eq "[Wed, 13 Feb 2013 12:30:00 UTC +00:00, Thu, 14 Feb 2013 12:30:00 UTC +00:00, Fri, 15 Feb 2013 12:30:00 UTC +00:00]"
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

  context "when its a new user without previous appointments or matches" do 
    it "should return a hash of users with the values being only times the user has" do
      Match.build_all_matches_for(@simran, Time.current.end_of_week)
      @simran.reload.matches.map(&:match_time).to_s.should eq "[Wed, 13 Feb 2013 12:30:00 UTC +00:00, Thu, 14 Feb 2013 12:30:00 UTC +00:00, Fri, 15 Feb 2013 12:30:00 UTC +00:00]"
    end

    it "should only return for users who are available" do
      Match.build_all_matches_for(@sharad, Time.current.end_of_week).should eq nil
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