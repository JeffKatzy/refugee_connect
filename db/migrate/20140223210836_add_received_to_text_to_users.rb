class AddReceivedToTextToUsers < ActiveRecord::Migration
  def change
    add_column :text_to_users, :received, :string
  end
end
