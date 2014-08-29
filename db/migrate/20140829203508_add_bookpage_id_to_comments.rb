class AddBookpageIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :bookpage_id, :integer
  end
end
