require 'spec_helper'

describe SpecificOpeningMatcher do
	describe '#matches_and_creates_apts' do
		let(:tutor_confirmed_opening) { FactoryGirl.create :specific_opening, 
			status: 'confirmed', 
			user_role: 'tutor',
			scheduled_for: time_tutor,
			user: FactoryGirl.create(:tutor_available), scheduled_for: time_tutor }
		let(:tutor_unconfirmed_opening) { FactoryGirl.create :specific_opening, 
			status: 'available', 
			user_role: 'tutor',
			scheduled_for: time_tutor,
			user: FactoryGirl.create(:tutor_available) }
		let(:tutor_openings) { [tutor_confirmed_opening, tutor_unconfirmed_opening] }

		before do
			@tutee_confirmed_opening_1 = FactoryGirl.create(:specific_opening, 
				status: s_o_tutee_status, 
				scheduled_for:  time_tutee,
				user_role: 'tutee',
				user: FactoryGirl.create(:tutee_available) )
			@tutee_confirmed_opening_2 = FactoryGirl.create(:specific_opening, 
				status: s_o_tutee_status, 
				scheduled_for:  time_tutee,
				user_role: 'tutee',
				user: FactoryGirl.create(:tutee_available) )
			@tutee_confirmed_opening_3 = FactoryGirl.create(:specific_opening, 
				status: s_o_tutee_status,
				scheduled_for:  time_tutee,
				user_role: 'tutee',
				user: FactoryGirl.create(:tutee_available) )
		end

		let(:tutee_openings) { [@tutee_confirmed_opening_1, @tutee_confirmed_opening_2, @tutee_confirmed_opening_3] }

			context "when no s_os are upcoming" do
				let(:time_tutee) {Time.current + 3.hours }
				let(:time_tutor) {Time.current + 3.hours }
				let(:s_o_tutee_status) {'confirmed'}

				it "matches for related users" do

					som = SpecificOpeningMatcher.new(tutor_openings)
					expect(som).to receive(:match_from_related_users).with(tutor_openings.first)
					expect(som).to receive(:match_from_related_users).with(tutor_openings.last)
					som.matches_and_creates_apts
				end
			end

			context "when s_os are upcoming" do
				let(:time_tutor) {Time.current + 1.hour }
				let(:time_tutee) {Time.current + 1.hour }
				let(:s_o_tutor_status) {'confirmed'}
				let(:s_o_tutee_status) {'confirmed'}

				it "matches for unrelated users" do
					som = SpecificOpeningMatcher.new(tutor_openings)
					expect(som).to receive(:match_from_unrelated_users).with(tutor_openings.first)
					expect(som).to receive(:match_from_unrelated_users).with(tutor_openings.last)
					som.matches_and_creates_apts
				end

				context "and there is a match" do
					let(:time_tutor) {Time.current + 1.hour }
					let(:time_tutee) {Time.current + 1.hour }

					before do
						som = SpecificOpeningMatcher.new(tutor_openings)
						som.matches_and_creates_apts
					end

					it "creates an appointment" do 
						expect(tutor_openings.first.appointment).to be_present
						expect(tutor_openings.map(&:appointment).compact.count).to eq 1
					end

					it "sets the status to taken for confirmed appointments" do 
						expect(tutor_openings.first.status).to eq 'taken'
					end
					it "does not create an appointment for unconfirmed openings" do 
						expect(tutor_openings.last.status).to eq 'available'
						expect(tutor_openings.last.appointment).to_not be_present
					end
				end
			end

		context "when not confirmed" do 
			let(:s_o_tutee_status) {'requested_confirmation'}
			let(:time_tutee) {Time.current + 3.hours }
			let(:time_tutor) {Time.current + 3.hours }

			it "does not select the opening" do
				tutee_openings.first.should_not_receive(:match_from_unrelated_users)
				tutee_openings.first.should_not_receive(:match_from_related_users)
				som = SpecificOpeningMatcher.new(tutor_openings)
				som.matches_and_creates_apts
			end
		end
	end

	describe '#match_from_related_users' do 
	  	before do 
		  	@apt = FactoryGirl.create(:appointment)
		  	@tutor = @apt.tutor
		  	@tutee = @apt.tutee
		  	@random_user = FactoryGirl.create(:tutor_available)
		  	@s_o_random_tutor = FactoryGirl.create(:specific_opening, user: @random_user)
		  	@s_o_tutor = FactoryGirl.create(:specific_opening, user_id: @tutor.id, status: s_o_tutor_status)
		  	@s_o_tutee = FactoryGirl.create(:specific_opening, user_id: @tutee.id, status: s_o_tutee_status)
		  	@s_os = [@s_o_random_tutor, @s_o_tutor, @s_o_tutee]
		  	@som = SpecificOpeningMatcher.new(@s_os)
	  	end

		context "when a tutor" do
		  context "when tutor status is confirmed and tutee status is confirmed" do 
		  	let(:s_o_tutor_status) { 'confirmed' }
		  	let(:s_o_tutee_status) { 'confirmed' }

		  	it "returns the S O from the appointment partner" do
		  		expect(@som.match_from_related_users(@s_o_tutor)).to eq @s_o_tutee
		  	end

		  	it "returns nil when there is no match from users apt partners" do 
		  		expect(@som.match_from_related_users(@s_o_random_tutor)).to eq nil
		  	end
		  end

		  context "when tutor status is not confirmed" do 
		  	let(:s_o_tutor_status) { 'available' }
		  	let(:s_o_tutee_status) { 'confirmed' }

		  	it "does not return the S O from the appointment partner" do 
		  		expect(@som.match_from_related_users(@s_o_tutor)).to eq nil
		  	end
		  end

		  context "when tutee status is not requested confirmation" do 
		  	let(:s_o_tutor_status) { 'confirmed' }
		  	let(:s_o_tutee_status) { 'available' }

		  	it "does not return the S O from the appointment partner" do 
		  		expect(@som.match_from_related_users(@s_o_tutor)).to eq nil
		  	end
		  end
		end

		context "when a tutee" do
		  context "when tutor status is confirmed and tutee status is confirmed" do 
		  	let(:s_o_tutor_status) { 'confirmed'}
		  	let(:s_o_tutee_status) { 'confirmed'}

		  	it "returns the S O from the appointment partner" do 
		  		expect(@som.match_from_related_users(@s_o_tutee)).to eq @s_o_tutor
		  	end
		  end

		  context "when tutor status is not confirmed" do 
		  	let(:s_o_tutor_status) { 'available' }
		  	let(:s_o_tutee_status) { 'confirmed' }

		  	it "does not return the S O from the appointment partner" do 
		  		expect(@som.match_from_related_users(@s_o_tutee)).to eq nil
		  	end
		  end

		  context "when tutee status is not requested confirmation" do 
		  	let(:s_o_tutor_status) { 'confirmed' }
		  	let(:s_o_tutee_status) { 'available' }

		  	it "does not return the S O from the appointment partner" do
		  		expect(@som.match_from_related_users(@s_o_tutee)).to eq nil
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
			@s_os = [@s_o_unrelated_tutor_different_time, @s_o_unrelated_tutor_same_time]

			@som = SpecificOpeningMatcher.new(@s_os)
		end

		context "when the tutees status is confrimed and the tutors status is confirmed" do 
			let(:s_o_tutor_status) { 'confirmed' }
			let(:s_o_tutee_status) { 'confirmed' }

	  	it "matches s_os with the same time" do
	  		expect(@som.match_from_unrelated_users(s_o_tutee)).to eq @s_o_unrelated_tutor_same_time
	  	end

	  	it "does not match s_os with the different times" do
	  		expect(@som.match_from_unrelated_users(@s_o_unrelated_tutor_different_time)).to eq nil
	  	end
	  end

	  context "when the tutees status is not confirmed and the tutors status is available" do 
	  	let(:s_o_tutor_status) { 'confirmed' }
			let(:s_o_tutee_status) { 'available' }
			
	  	it "does not match s_os with the same time" do
	  		expect(@som.match_from_unrelated_users(s_o_tutee)).to eq nil
	  	end
	  end
	end

	#write create appointment method
end