# == Schema Information
#
# Table name: availabilities
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  per_week      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  schedule_hash :text
#

require 'spec_helper'

describe Availability do


  let(:availability) { FactoryGirl.create(:availability) }

  it "should have a valid factory" do
    availability.should be_valid
  end

  describe "#schedule" do
  end

  describe "#availabilities" do
  end

  describe "#add_weekly_availability" do
    before :each do
      availability.add_weekly_availability('monday', 1)
    end

    it "should add times available" do
      availability.schedule.recurrence_rules.count should eq 1
      availability.add_weekly_availability('tuesday', 4)
      availability.schedule.recurrence_rules.count should eq 2
    end
  end

  



  describe "remove availability" do
    it "should remove available times" do
    end
  end
end
