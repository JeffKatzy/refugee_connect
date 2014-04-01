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

class Facebook < ActiveRecord::Base
	belongs_to :user
  attr_accessible :add_facebook_info_to_users, :oauth_expires_at, :oauth_token, :uid, :profile_picture
  attr_accessor :new_user

  def facebook_koala
    @facebook_koala ||= Koala::Facebook::API.new(oauth_token)
  end

  def friends
    facebook_koala.fql_query('SELECT name, pic_square, uid FROM user WHERE uid in (SELECT uid2 FROM friend WHERE uid1=me())')
  end

  def college_friends
    query(self.college, 'education')
  end
end
