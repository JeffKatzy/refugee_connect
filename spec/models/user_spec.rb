# == Schema Information
#
# Table name: users
#
#  id               :integer          not null, primary key
#  email            :string(255)
#  password_digest  :string(255)
#  cell_number      :string(255)
#  role             :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  admin            :boolean
#  name             :string(255)
#  active           :boolean
#  per_week         :integer
#  uid              :string(255)
#  oauth_token      :string(255)
#  oauth_expires_at :datetime
#  image            :string(255)
#  time_zone        :string(255)
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
  		@janie = FactoryGirl.create(:tutor_available, active: false)
  		@joey = FactoryGirl.create(:tutor_available, active: false)
  		@priya = FactoryGirl.create(:tutor_available, active: true)
  		@jaya = FactoryGirl.create(:tutor_available, active: true)
      @joey.active = false
      @joey.save
  	end

  	it "returns only active users" do
  		User.tutors.should include @priya
      User.tutors.should include @jaya
  	end

  	it "does not return inactive users" do
  		User.tutors.should_not include @joey
  	end
  end

  describe '#format_cell_number' do
    it "should add a US country code for tutors" do
      tutor = FactoryGirl.create(:tutor_unavailable)
      tutor.cell_number[0].should eq "1"
    end

    it "should add an Indian country code for tutees" do
      tutee = FactoryGirl.create(:tutee_unavailable)
      tutee.cell_number[0].should eq "9"
      tutee.cell_number[1].should eq "1"
    end
  end

  describe "#appointments_less_than_accepted_amount" do
    before :each do
      time = DateTime.new 2013,02,14,12,30,00
      Timecop.travel(time.beginning_of_week)
    end

    it "should return true when the number of appointments is less" do
      tutor = FactoryGirl.create(:tutor_unavailable, per_week: 4)
      tutor.appointments_less_than_accepted_amount(Time.current.end_of_week).should eq true
    end

    it "should return false when the number of appointments is more" do
      tutor = FactoryGirl.create(:tutor_unavailable, per_week: 3)
      tutor.appointments_less_than_accepted_amount(Time.current.end_of_week).should eq false
    end
  end

  describe "#available_before?(datetime)" do
  	before :each do
      @time = DateTime.new(2013,02,14,12,30,00)
      Timecop.travel(@time.beginning_of_week)
      @jaya = FactoryGirl.create(:tutor_available)
  		@priya = FactoryGirl.create(:tutor_unavailable)
  		@joey = FactoryGirl.create(:tutor_unavailable)
  	end

  	it "returns false for users whose classes are equal to the appointments per week" do
  		@priya.available_before?(Time.current.end_of_week).should eq false
  	end

    it "returns true for users whose classes are less than the appointments per week" do 
      @jaya.available_before?(Time.current.end_of_week).should eq true
    end
  end

  describe '#intersections' do
    before :each do
      time = DateTime.new(2013,02,14,12,30,00)
      Timecop.travel(time.beginning_of_week)
      @priya = FactoryGirl.create(:tutor_available)
      @jaya = FactoryGirl.create(:tutor_available)
    end

    it "should return the intersecting times" do
      @jaya.intersections(@priya, Time.current.end_of_week).count.should eq 3
    end

    it "should not matter the direction" do
      @priya.intersections(@jaya, Time.current.end_of_week).count.should eq 3
    end
  end

  describe "#opposite_active_users" do
    before :each do
      @devin = FactoryGirl.create(:tutor_available)
      @simran = FactoryGirl.create(:tutor_available)

      @nitika = FactoryGirl.create(:tutee_available)
      @ruchi = FactoryGirl.create(:tutee_unavailable)
      @pooja = FactoryGirl.create(:tutee_unavailable)      
    end

    it "should return an array of active users with the opposite role" do
      @simran.opposite_active_users.should include @nitika, @ruchi, @pooja
    end

    it "should return an array of active users with the same role" do
      @simran.opposite_active_users.should_not include @devin
    end
  end

  describe '#available_appointments_before(datetime)' do
    before :each do
      time = DateTime.new(2013,02,14,12,30,00)
      Timecop.travel(time.beginning_of_week)
      @simran = FactoryGirl.create(:tutor_available)
      @nitika = FactoryGirl.create(:tutee_available)
      @sharad = FactoryGirl.create(:tutee_unavailable)
    end

    it "should return a hash of users with the values being only times the user has" do
      @simran.available_appointments_before(Time.current.end_of_week).first[:times].to_s.should eq "[Wed, 13 Feb 2013 12:30:00 UTC +00:00, Thu, 14 Feb 2013 12:30:00 UTC +00:00, Fri, 15 Feb 2013 12:30:00 UTC +00:00]"
    end

    it "should only return for users who are available" do
      @sharad.available_appointments_before(Time.current.end_of_week).should eq []
    end
  end
end
