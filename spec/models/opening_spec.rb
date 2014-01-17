# == Schema Information
#
# Table name: openings
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  day_open   :string(255)
#  time       :datetime
#  time_open  :string(255)
#

require 'spec_helper'

describe Opening do
  describe "#set_time" do 
  		let(:tutor) { FactoryGirl.create :tutor_available }
  		let(:opening) { FactoryGirl.create(:opening, day_open: "Monday", time_open: "9 pm", user: tutor) } 
  		
  	it "should create the time in the users time zone" do 
  		expect(opening.time.time_zone.to_s).to eq '(GMT-05:00) America/New_York'
  	end

  	it "should save that time on the proper weekday" do
  		expect(opening.time.strftime("%A")).to eq "Monday"
  	end

  	it "should save that time at the proper time" do
  		expect(opening.time.hour).to eq 21
  	end
  end
end
