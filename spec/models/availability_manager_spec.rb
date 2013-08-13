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

  describe "#schedule" do
  end

  describe "#availabilities" do
  end

  describe "#add_weekly_availability" do
    before :each do
      availability_manager.add_weekly_availability('monday', 1)
    end

    it "should add times available" do
      availability_manager.schedule.recurrence_rules.count should eq 1
      availability_manager.add_weekly_availability('tuesday', 4)
      availability_manager.schedule.recurrence_rules.count should eq 2
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
