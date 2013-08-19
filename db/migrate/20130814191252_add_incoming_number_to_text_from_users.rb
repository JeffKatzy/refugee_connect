class AddIncomingNumberToTextFromUsers < ActiveRecord::Migration
  def change
    add_column :text_from_users, :incoming_number, :string
  end
end
