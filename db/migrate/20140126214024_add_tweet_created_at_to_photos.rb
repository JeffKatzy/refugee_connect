class AddTweetCreatedAtToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :tweet_created_at, :datetime
  end
end
