# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email           :string(255)
#  password_digest :string(255)
#  cell_number     :string(255)
#  role            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  admin           :boolean
#  name            :string(255)
#  active          :boolean
#  per_week        :integer
#

require 'spec_helper'

describe User do
  it 'has a valid factory' do
    FactoryGirl.create(:user).should be_valid
  end

  describe ".tutors" do
  	before :each do
  		@janie = FactoryGirl.create(:user, role: 'tutor')
  		@joey = FactoryGirl.create(:user, role: 'tutor')
  		@priya = FactoryGirl.create(:user, role: 'tutee')
  		@jaya = FactoryGirl.create(:user, role: 'tutee')
  	end

  	it "returns only users marked as tutor" do
  		User.tutors.should eq [@janie, @joey]
  	end

  	it "does not return users marked as tutee" do
  		User.tutors.should_not include @priya
  	end
  end

  describe ".tutees" do
  	before :each do
  		@janie = FactoryGirl.create(:user, role: 'tutor')
  		@joey = FactoryGirl.create(:user, role: 'tutor')
  		@priya = FactoryGirl.create(:user, role: 'tutee')
  		@jaya = FactoryGirl.create(:user, role: 'tutee')
  	end

  	it "returns only tutees" do
  		User.tutees.should eq [@priya, @jaya]
  	end

  	it "does not return tutors" do
  		User.tutees.should_not include @joey
  	end
  end

  describe ".tutors" do
  	before :each do
  		@janie = FactoryGirl.create(:user, active: false)
  		@joey = FactoryGirl.create(:user, active: false)
  		@priya = FactoryGirl.create(:user, active: true)
  		@jaya = FactoryGirl.create(:user, active: true)
  	end

  	it "returns only active users" do
  		User.active.should eq [@priya, @jaya]
  	end

  	it "does not return inactive users" do
  		User.active.should_not include @joey
  	end
  end

  describe "#available_this_week?" do
  	before :each do
      @jaya = FactoryGirl.create(:tutor_available)
  		@priya = FactoryGirl.create(:tutor_unavailable)
  		@janie = FactoryGirl.create(:tutor_overbooked)
  		@joey = FactoryGirl.create(:tutor_unavailable)
  	end

    it "returns false for users who have rules less than or equal to the number of appointments" do
      @jaya.available_this_week?
    end

  	it "returns false for users whose classes are equal to the apptments per week" do
  		@priya.available_this_week?.should eq false
  	end

    it "returns true for users whose classes are less than the apptments per week" do 
      @jaya.available_this_week?.should eq true
    end

    it "returns 'overbooked' for users whose classes are more than the apptments per week" do 
      @janie.available_this_week?.should eq 'overbooked'
    end
  end

  describe '#intersects_with' do
    before :each do
      @priya = FactoryGirl.create(:tutor_unavailable)
      @jaya = FactoryGirl.create(:tutor_available)
    end

    it "should return the intersecting times" do
      @jaya.intersections(@priya).count.should eq 2
    end

    it "should not matter the direction" do
      @priya.intersections(@jaya).count.should eq 2
    end
  end

  describe "#opposite_active_users" do
    before :each do
      @devin = FactoryGirl.create(:tutor_unavailable)
      @simran = FactoryGirl.create(:tutor_available)

      @nitika = FactoryGirl.create(:tutee_available)
      @ruchi = FactoryGirl.create(:tutee_unavailable)
      @priya = FactoryGirl.create(:tutee_overbooked)
      @pooja = FactoryGirl.create(:tutee_unavailable)      
    end

    it "should return an array of active users with the opposite role" do
      @simran.opposite_active_users.should eq [@nitika, @ruchi, @priya, @pooja]
    end
  end

  describe '#available_appointments_this_week' do

    before :each do
      @devin = FactoryGirl.create(:tutor_unavailable)
      @simran = FactoryGirl.create(:tutor_available)

      @nitika = FactoryGirl.create(:tutee_available)
      @ruchi = FactoryGirl.create(:tutee_unavailable)
      @priya = FactoryGirl.create(:tutee_overbooked)
      @pooja = FactoryGirl.create(:tutee_unavailable)      
    end

    it "should return a hash of users with the values being only times the user has" do
      @simran.available_appointments_this_week.values.each do |value|
        value.to_s.should eq "[2013-08-09 04:00:00 -0400]"
      end
    end

    it "should only return for users who are available" do
      @devin.available_appointments_this_week.should eq 'user has no remaining availabilities this week.'
    end
  end
end
