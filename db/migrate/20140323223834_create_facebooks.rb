class CreateFacebooks < ActiveRecord::Migration
  def change
    create_table :facebooks do |t|
      t.string :add_facebook_info_to_users
      t.string :uid
      t.string :oauth_token
      t.string :profile_picture
      t.datetime :oauth_expires_at

      t.timestamps
    end
  end
end
