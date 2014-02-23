# == Schema Information
#
# Table name: matches
#
#  id         :integer          not null, primary key
#  tutor_id   :integer
#  tutee_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  match_time :datetime
#  available  :boolean
#

# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :match do
    match_time DateTime.new 2013,02,14,12,30,00

    before(:create) do |match|
    	if match.tutee.nil?
    		match.tutee = FactoryGirl.create(:tutee_available)
    	end
    	if match.tutor.nil?
    		match.tutor = FactoryGirl.create(:tutor_available)
    	end
    end
  end
end
