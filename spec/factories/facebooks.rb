# == Schema Information
#
# Table name: facebooks
#
#  id                         :integer          not null, primary key
#  add_facebook_info_to_users :string(255)
#  uid                        :string(255)
#  oauth_token                :string(255)
#  profile_picture            :string(255)
#  oauth_expires_at           :datetime
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  user_id                    :integer
#  provider                   :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :facebook do
    add_facebook_info_to_users "MyString"
    uid "MyString"
    oauth_token "MyString"
    oauth_expires_at "2014-03-23 18:38:34"
  end
end
