# == Schema Information
#
# Table name: assignments
#
#  id           :integer          not null, primary key
#  instructions :text
#  lesson_id    :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'spec_helper'

describe Assignment do
  describe '#lesson' do
  	let(:assignment) { FactoryGirl.create(:assignment)}

  	it "responds to lesson" do
  		expect(assignment.lesson).to_not raise_error
  	end
  end
end
