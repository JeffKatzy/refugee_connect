# == Schema Information
#
# Table name: specific_openings
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  opening_id     :integer
#  appointment_id :integer
#  scheduled_for  :datetime
#  status         :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_role      :string(255)
#

require 'spec_helper'

describe SpecificOpening do
	describe '#confirm' do
		
		before do
			specific_opening.reload
			specific_opening.confirm
		end

		let(:specific_opening) { FactoryGirl.create(:specific_opening, user: (FactoryGirl.create :user)) }

		it "creates a new confirmation" do
			specific_opening.confirm
			expect(specific_opening.confirmations).to be_present
		end

		it "has the correct user" do
			specific_opening.confirm
			confirmation = specific_opening.confirmations.first
			expect(confirmation.user).to eq specific_opening.user
		end

		it "has the correct attribute" do
			specific_opening.confirm
			confirmation = specific_opening.confirmations.first
			expect(confirmation.confirmed).to eq true
		end
	end
end
