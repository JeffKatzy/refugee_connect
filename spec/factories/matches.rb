# Read about factories at https://github.com/thoughtbot/factory_girl

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
#


FactoryGirl.define do
  factory :match do
    match_time DateTime.new 2013,02,14,12,30,00

    after(:build) do |match|
      match.tutee = FactoryGirl.build(:tutee_available) unless match.tutee.present?
      match.tutor = FactoryGirl.build(:tutor_available) unless match.tutor.present?
      match.save
    end
  end
end
