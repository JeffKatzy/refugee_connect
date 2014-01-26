class AddAndChangeTweetIdToUsers < ActiveRecord::Migration
  def change
  	remove_column :photos, :tweet_id
    add_column :photos, :tweet_id, :integer, limit: 8
  end
end
