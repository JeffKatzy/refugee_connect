# == Schema Information
#
# Table name: profile_infos
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  age           :string(255)
#  interests     :text
#  english_focus :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class ProfileInfo < ActiveRecord::Base
  attr_accessible :age, :english_focus, :interests, :user_id
  belongs_to :user
end
