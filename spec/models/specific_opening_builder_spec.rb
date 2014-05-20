require 'spec_helper'

describe SpecificOpeningBuilder do
	describe '#build_specific_openings' do 
    let(:time1) { Time.current.beginning_of_week.change(hour: 21, minute: 30) }
    let(:time2) { Time.current.beginning_of_week.change(hour: 22, minute: 30) + 1.day }
    let(:opening1) { FactoryGirl.create(:opening, day_open: 'Sunday', time_open: '9:30 pm' ) }
    let(:opening2) { FactoryGirl.create(:opening, day_open: 'Monday', time_open: '9:30 pm' ) }
    let(:openings) { [opening1, opening2] }
    let(:specific_opening_builder) { SpecificOpeningBuilder.new(openings) }
    let(:specific_opening_1) { specific_opening_builder.specific_openings.first }

    before do
    	opening1
    	opening2
    	Timecop.travel(Time.current.beginning_of_week + 14.days)
    	specific_opening_builder
    	specific_opening_builder.build_specific_openings
    end

    it "builds the specific_opening with the same weekday" do
      expect(specific_opening_1.scheduled_for.utc.wday).to eq opening1.time.utc.wday
    end

    it "builds the specific_opening with the same hour" do
      expect(specific_opening_1.scheduled_for.utc.hour).to eq opening1.time.utc.hour
    end

    it "builds the specific_opening with the same minute" do
      expect(specific_opening_1.scheduled_for.utc.min).to eq opening1.time.utc.min
    end

    it "builds the specific opening for the current week" do
      expect(specific_opening_1.scheduled_for.beginning_of_week).to eq Time.current.beginning_of_week
    end
	end
end