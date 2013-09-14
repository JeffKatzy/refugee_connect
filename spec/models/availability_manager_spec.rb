# == Schema Information
#
# Table name: availability_managers
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  per_week      :integer
#  schedule_hash :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe AvailabilityManager do

  let(:availability_manager) { FactoryGirl.create(:availability_manager) }

  it "should have a valid factory" do
    availability_manager.should be_valid
  end

  it "should have an initialized schedule with a start time in EST" do
    availability_manager.schedule.start_time.zone.should == "EDT"
  end

  describe '#init_schedule' do
    it "should add a new schedule" do 
      availability_manager.init_schedule
      availability_manager.schedule_hash.should be_a_kind_of(Hash)
    end

    it 'should have a start time in EST' do
      availability_manager.init_schedule
      availability_manager.schedule.start_time.zone.should == "EDT"
    end
  end

  describe '#create_rule' do 
    it "should create an ice_cube rule" do
      rule = availability_manager.create_rule('monday', 1)
      rule.to_s.should include "Weekly on Mondays on the 1st hour of the day"
    end
  end

  describe "#add_recurrence" do
    it "should add the rule to the schedule" do
      availability_manager.create_rule(:tuesday, 3).to_s.should include "Weekly on Tuesdays on the 3rd hour of the day"
    end
  end

  describe "#add_weekly_availability" do
    it "should add multiple available times" do
      availability_manager.add_weekly_availability('Monday', 1)
      availability_manager.add_weekly_availability('Tuesday', 3)
      availability_manager.schedule.to_s.should include "Weekly on Mondays on the 1st hour of the day", "Weekly on Tuesdays on the 3rd hour of the day"
    end
  end

  describe "#save_schedule_hash" do
    before :each do
      availability_manager.add_weekly_availability('monday', 1)
    end

    it "should save the availability manager" do 
      availability_manager.save_schedule  
      availability_manager.schedule_hash.class.should eq Hash
    end
  end

  describe '#availabilities_this_week' do
    before :each do
      availability_manager.add_weekly_availability('saturday', 12)
    end

    it "should return all availabilities this week" do
      availability_manager.remaining_occurrences_this_week.count.should eq 1
    end
  end
end
