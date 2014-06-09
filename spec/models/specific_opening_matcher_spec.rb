require 'spec_helper'

describe SpecificOpeningMatcher do
	describe '#matches_users_and_creates_apts' do
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
				status: status, 
				scheduled_for:  time_tutee,
				user_role: 'tutee',
				user: FactoryGirl.create(:tutee_available) )
			@tutee_confirmed_opening_2 = FactoryGirl.create(:specific_opening, 
				status: 'confirmed', 
				scheduled_for:  time_tutee,
				user_role: 'tutee',
				user: FactoryGirl.create(:tutee_available) )
			@tutee_confirmed_opening_3 = FactoryGirl.create(:specific_opening, 
				status: 'confirmed',
				scheduled_for:  time_tutee,
				user_role: 'tutee',
				user: FactoryGirl.create(:tutee_available) )
		end

		let(:tutee_openings) { [@tutee_confirmed_opening_1, @tutee_confirmed_opening_2, @tutee_confirmed_opening_3] }

			context "when no s_os are upcoming" do
				let(:time_tutee) {Time.current + 3.hours }
				let(:time_tutor) {Time.current + 3.hours }
				let(:status) {'confirmed'}

				it "matches for related users" do
					tutor_openings.first.should_receive(:match_from_related_users)
					som = SpecificOpeningMatcher.new(tutor_openings)
					som.matches_users_and_creates_apts
				end
			end

			context "when s_os are upcoming" do
				let(:time_tutor) {Time.current + 1.hour }
				let(:time_tutee) {Time.current + 1.hour }
				let(:status) {'confirmed'}

				it "matches for unrelated users" do
					tutor_openings.first.should_receive(:match_from_unrelated_users)
					som = SpecificOpeningMatcher.new(tutor_openings)
					som.matches_users_and_creates_apts
				end

				context "and there is a match" do
					let(:time_tutor) {Time.current + 1.hour }
					let(:time_tutee) {Time.current + 1.hour }

					before do
						som = SpecificOpeningMatcher.new(tutor_openings)
						som.matches_users_and_creates_apts
					end

					it "creates an appointment" do 
						expect(tutor_openings.first.appointment).to be_present
						expect(tutor_openings.map(&:appointment).compact.count).to eq 1
					end

					it "sets the status to taken" do 
						expect(tutor_openings.first.status).to eq 'taken'
						expect(tutor_openings.last.status).to eq 'available'
					end
				end
			end

			context "when not confirmed" do 
				let(:status) {'available'}
				let(:time_tutee) {Time.current + 3.hours }
				let(:time_tutor) {Time.current + 3.hours }

				it "does not select the opening" do
					tutee_openings.first.should_not_receive(:match_from_unrelated_users)
					tutee_openings.first.should_not_receive(:match_from_related_users)
					som = SpecificOpeningMatcher.new(tutor_openings)
					som.matches_users_and_creates_apts
				end
			end
	end
end