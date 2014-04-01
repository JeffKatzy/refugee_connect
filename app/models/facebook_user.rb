# == Schema Information
#
# Table name: facebook_users
#
#  id               :integer          not null, primary key
#  uid              :string(255)
#  provider         :string(255)
#  oauth_token      :string(255)
#  profile_picture  :string(255)
#  oauth_expires_at :string(255)
#  user_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class FacebookUser < ActiveRecord::Base
	belongs_to :user
  attr_accessible :oauth_expires_at, :oauth_token, :profile_picture, :provider, :uid, :user_id
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
