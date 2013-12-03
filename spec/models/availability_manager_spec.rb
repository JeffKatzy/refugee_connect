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

  describe '.create' do
    it "should add a new schedule" do 
      availability_manager.schedule_hash.should be_a_kind_of(Hash)
    end

    it 'should have a start time in the users timezone' do 
      availability_manager.schedule.start_time.zone.should == "UTC"
    end
  end

  describe "#remove_occurrence" do
    it "should remove the availability for the correct time" do
      mon = FactoryGirl.create(:monday)
      first_time = mon.schedule.occurrences(Time.now.end_of_week + 7.days).first.time
      mon.remove_occurrence(first_time)
      mon.schedule.occurring_between?(first_time, first_time + 1.hour).should be false
    end
  end

  describe '#create_rule' do 
    it "should create an ice_cube rule with a time object" do
      time = DateTime.new 2013,02,14,12,30,00
      rule = availability_manager.create_rule('monday', time)
      rule.to_s.should include "Weekly on Mondays on the 12th hour of the day on the 30th minute of the hour"
    end
  end

  describe "#add_recurrence" do
    it "should add the rule to the schedule" do
      time = DateTime.new 2013,02,14,3,30,00
      availability_manager.create_rule(:tuesday, time).to_s.should include "Weekly on Tuesdays on the 3rd hour of the day"
    end
  end

  describe "#add_weekly_availability" do
    it "should add multiple available times with a time object" do
      time = DateTime.new 2013,02,14,12,30,00
      availability_manager.add_weekly_availability('Monday', time)
      availability_manager.add_weekly_availability('Tuesday', time)
      availability_manager.schedule.to_s.should include "Weekly on Mondays on the 12th hour of the day on the 30th minute of the hour", "Weekly on Tuesdays on the 12th hour of the day on the 30th minute of the hour"
    end
  end

  describe "#save_schedule_hash" do
    before :each do
      time = DateTime.new 2013,02,14,12,30,00
      availability_manager.add_weekly_availability('monday', time)
    end

    it "should save the availability manager" do 
      availability_manager.save_schedule  
      availability_manager.schedule_hash.class.should eq Hash
    end
  end

  describe '#remaining_occurrences(datetime)' do
    before :each do
      time = DateTime.new 2013,02,14,12,30,00
      Timecop.travel(time)
      availability_manager.add_weekly_availability('saturday', time)
    end

    it "should return all availabilities this week" do
      availability_manager.remaining_occurrences(Time.current.end_of_week).count.should eq 1
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
      @priya.availability_manager.available_before?(Time.current.end_of_week).should eq false
    end

    it "returns true for users whose classes are less than the appointments per week" do 
      @jaya.availability_manager.available_before?(Time.current.end_of_week).should eq true
    end
  end
end
