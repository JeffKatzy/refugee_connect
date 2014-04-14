# == Schema Information
#
# Table name: text_coordinators
#
#  id             :integer          not null, primary key
#  appointment_id :integer
#  user_id        :integer
#  text_signup_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'spec_helper'

describe TextCoordinator do
  describe '.coordinate' do
  	context "when a reminder text is sent" do
  		it "stores the associated appointment" do
  		end

  		it "stores the associated user" do
  		end
  	end
  end
end
