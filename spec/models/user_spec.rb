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
#  twitter_handle   :string(255)
#

require 'spec_helper'

describe User do
  it 'has a valid factory' do
    FactoryGirl.create(:user).should be_valid
  end

  describe ".tutors" do
  	before :each do
      User.destroy_all
  		@janie = FactoryGirl.create(:tutor_available)
  		@joey = FactoryGirl.create(:tutor_available)
  		@priya = FactoryGirl.create(:tutee_unavailable)
  		@jaya = FactoryGirl.create(:tutee_unavailable)
  	end

  	it "returns only users marked as tutor" do
  		User.tutors.should include @janie
      User.tutors.should include @joey
  	end

  	it "does not return users marked as tutee" do
  		User.tutors.should_not include @priya
  	end
  end

  describe ".tutees" do
  	before :each do
  		@janie = FactoryGirl.create(:tutee_available)
  		@joey = FactoryGirl.create(:tutor_available)
  		@priya = FactoryGirl.create(:tutee_available)
  		@jaya = FactoryGirl.create(:tutee_available)
  	end

  	it "returns only tutees" do
  		User.tutees.should include @priya
      User.tutees.should include @jaya
  	end

  	it "does not return tutors" do
  		User.tutees.should_not include @joey
  	end
  end

  describe ".tutors" do
  	before :each do
  		@janie = FactoryGirl.create(:tutor_available, active: false)
  		@joey = FactoryGirl.create(:tutor_available, active: false)
  		@priya = FactoryGirl.create(:tutee_available, active: true)
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

  describe '#appointment_partners' do
    before :each do
      @priya = FactoryGirl.create(:tutee_available, active: true)
      @janie = FactoryGirl.create(:tutor_available, active: false)
      apt_same_user = FactoryGirl.create(:appointment, tutor: @janie, tutee: @janie)
      apt_diff_users = FactoryGirl.create(:appointment, tutor: @janie, tutee: @priya)
    end

    it "does not return the user itself" do 
      expect(@janie.appointment_partners).to_not include(@janie)
    end

    it "returns the other users" do
      expect(@janie.appointment_partners).to include(@priya)
    end
  end

  describe '#format_cell_number' do
    it "should add a US country code for tutors" do
      tutor = FactoryGirl.create(:tutor_unavailable)
      tutor.cell_number.should include "+1"
    end

    it "should add an Indian country code for tutees" do
      tutee = FactoryGirl.create(:tutee_unavailable)
      tutee.cell_number.should include "+91"
    end
  end
end
