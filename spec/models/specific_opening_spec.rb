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
		  	@s_o_tutor = FactoryGirl.create(:specific_opening, user_id: @tutor.id, status: s_o_tutor_status)
		  	@s_o_tutee = FactoryGirl.create(:specific_opening, user_id: @tutee.id, status: s_o_tutee_status)
	  	end

		context "when a tutor" do
		  context "when tutor status is confirmed and tutee status is requested confirmation" do 
		  	let(:s_o_tutor_status) { 'confirmed' }
		  	let(:s_o_tutee_status) { 'requested_confirmation' }

		  	it "returns the S O from the appointment partner" do
		  		#this should fail 
		  		expect(@s_o_tutor.match_from_related_users).to eq @s_o_tutee
		  	end

		  	it "returns nil when there is no match from users apt partners" do 
		  		expect(@s_o_random_tutor.match_from_related_users).to eq nil
		  	end
		  end

		  context "when tutor status is not confirmed" do 
		  	let(:s_o_tutor_status) { 'available' }
		  	let(:s_o_tutee_status) { 'requested_confirmation' }
		  	it "does not return the S O from the appointment partner" do 
		  		expect(@s_o_tutor.match_from_related_users).to eq nil
		  	end
		  end

		  context "when tutee status is not requested confirmation" do 
		  	let(:s_o_tutor_status) { 'confirmed' }
		  	let(:s_o_tutee_status) { 'available' }

		  	it "does not return the S O from the appointment partner" do 
		  		expect(@s_o_tutor.match_from_related_users).to eq nil
		  	end
		  end
		end

		context "when a tutee" do
		  context "when tutor status is confirmed and tutee status is requested confirmation" do 
		  	let(:s_o_tutor_status) { 'confirmed'}
		  	let(:s_o_tutee_status) { 'requested_confirmation'}

		  	it "returns the S O from the appointment partner" do 
		  		expect(@s_o_tutee.match_from_related_users).to eq @s_o_tutor
		  	end
		  end

		  context "when tutor status is not confirmed" do 
		  	let(:s_o_tutor_status) { 'available' }
		  	let(:s_o_tutee_status) { 'requested_confirmation' }
		  	it "does not return the S O from the appointment partner" do 
		  		expect(@s_o_tutee.match_from_related_users).to eq nil
		  	end
		  end

		  context "when tutee status is not requested confirmation" do 
		  	let(:s_o_tutor_status) { 'confirmed' }
		  	let(:s_o_tutee_status) { 'available' }

		  	it "does not return the S O from the appointment partner" do 
		  		expect(@s_o_tutee.match_from_related_users).to eq nil
		  	end
		  end
		end
	end

  describe '#match_unrelated_users' do
  	let(:tutee) { FactoryGirl.create(:tutee_available) }

  	let(:s_o_tutee)  { FactoryGirl.create(:specific_opening, user_id: tutee.id, 
  										user_role: 'tutee', 
  										status: s_o_tutee_status) }
  	let(:unrelated_tutor_same_time)  { FactoryGirl.create(:tutor_available) }

  	let(:unrelated_tutor_different_time)  { FactoryGirl.create(:tutor_available) }

  	before :each do 
			@s_o_unrelated_tutor_different_time = FactoryGirl.create(:specific_opening, 
		  		user: unrelated_tutor_different_time,
		  		scheduled_for: s_o_tutee.scheduled_for + 1.hour, 
		  		user_role: 'tutor', 
		  		status: s_o_tutor_status)

			@s_o_unrelated_tutor_same_time = FactoryGirl.create(:specific_opening, 
	  		user: unrelated_tutor_same_time, 
	  		scheduled_for: s_o_tutee.scheduled_for, 
	  		user_role: 'tutor', 
	  		status: s_o_tutor_status )
		end

		context "when the tutees status is requested confirmation and the tutors status is available" do 
			let(:s_o_tutor_status) { 'confirmed' }
			let(:s_o_tutee_status) { 'requested_confirmation' }
	  	it "matches s_os with the same time" do
	  		expect(s_o_tutee.match_from_unrelated_users).to eq @s_o_unrelated_tutor_same_time
	  	end

	  	it "does not match s_os with the different times" do
	  		expect(@s_o_unrelated_tutor_different_time.match_from_unrelated_users).to eq nil
	  	end
	  end

	  context "when the tutees status is not requested confirmation and the tutors status is available" do 
	  	let(:s_o_tutor_status) { 'confirmed' }
			let(:s_o_tutee_status) { 'available' }
			
	  	it "does not match s_os with the same time" do
	  		expect(s_o_tutee.match_from_unrelated_users).to eq nil
	  	end
	  end
	end
end
