# == Schema Information
#
# Table name: appointments
#
#  id            :integer          not null, primary key
#  status        :string(255)
#  start_page    :integer
#  finish_page   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  scheduled_for :text
#  user_id       :integer
#  began_at      :datetime
#  ended_at      :datetime
#

require 'spec_helper'

describe Appointment do
  it 'has a valid factory' do
		FactoryGirl.create(:appointment).should be_valid
	end

	describe '.after(this_week)' do
		before :each do
			@next_month = FactoryGirl.create(:appointment, scheduled_for: Time.now + 1.month )
			@next_month_plus = FactoryGirl.create(:appointment, scheduled_for: Time.now + 2.months )
			@this_week = FactoryGirl.create(:appointment, scheduled_for: Time.now + 1.day)
		end
	
		it "returns appointments after specified time" do
	  	Appointment.after(Time.now + 1.week).should eq [@next_month, @next_month_plus]
		end

		it "does not return users before the time" do
	  	Appointment.after(Time.now + 1.week).should_not include @this_week
		end
	end

	describe '.before(this_week)' do
		before :each do
			@next_month = FactoryGirl.create(:appointment, scheduled_for: Time.now + 1.month )
			@next_month_plus = FactoryGirl.create(:appointment, scheduled_for: Time.now + 2.months )
			@this_week = FactoryGirl.create(:appointment, scheduled_for: Time.now + 1.day)
		end

		it "returns appointments after specified time" do
	  	Appointment.before(Time.now + 2.weeks).should eq [@this_week]
		end

		it "does not return users before the time" do
	  	Appointment.before(Time.now + 2.weeks).should_not include @next_month, @next_month_plus
		end
	end
end
