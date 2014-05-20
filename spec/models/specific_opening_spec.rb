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
	describe '#match_from_related_users' do 
		
  	before do 
	  	@apt = FactoryGirl.create(:appointment)
	  	@tutor = @apt.tutor
	  	@tutee = @apt.tutee
	  	@random_user = FactoryGirl.create(:tutor_available)
	  	@s_o_random_tutor = FactoryGirl.create(:specific_opening, user: @random_user)
	  	@s_o_tutor = FactoryGirl.create(:specific_opening, user_id: @tutor.id, status: status)
	  	@s_o_tutee = FactoryGirl.create(:specific_opening, user_id: @tutee.id)
  	end

	  context "when confirmed" do 
	  	let(:status) { 'confirmed'}
	  	it "returns the S O from the appointment partner" do 
	  		expect(@s_o_tutee.match_from_related_users).to eq @s_o_tutor
	  	end

	  	it "returns nil when there is no match from users apt partners" do 
	  		expect(@s_o_random_tutor.match_from_related_users).to eq nil
	  	end
	  end

	  context "when not confirmed" do 
	  	let(:status) { 'available' }
	  	it "returns the S O from the appointment partner" do 
	  		expect(@s_o_tutee.match_from_related_users).to eq nil
	  	end
	  end
	end

  describe '#match_unrelated_users' do
  	let(:tutee) { FactoryGirl.create(:tutee_available) }
  	let(:s_o_tutee)  { FactoryGirl.create(:specific_opening, user_id: tutee.id, 
  		user_role: 'tutee', 
  		status: 'confirmed') }
  	let(:unrelated_tutor_same_time)  { FactoryGirl.create(:tutor_available) }
  	let(:unrelated_tutor_different_time)  { FactoryGirl.create(:tutor_available) }

  	before :each do 
			@s_o_unrelated_tutor_different_time = FactoryGirl.create(:specific_opening, 
		  		user: unrelated_tutor_different_time,
		  		scheduled_for: s_o_tutee.scheduled_for + 1.hour, 
		  		user_role: 'tutor', 
		  		status: 'confirmed')

			@s_o_unrelated_tutor_same_time = FactoryGirl.create(:specific_opening, 
	  		user: unrelated_tutor_same_time, 
	  		scheduled_for: s_o_tutee.scheduled_for, 
	  		user_role: 'tutor', 
	  		status: 'confirmed')
		end

  	it "matches s_os with the same time" do
  		expect(s_o_tutee.match_from_unrelated_users).to eq @s_o_unrelated_tutor_same_time
  	end

  	it "does not match s_os with the different times" do
  		expect(@s_o_unrelated_tutor_different_time.match_from_unrelated_users).to eq nil
  	end
	end
end
