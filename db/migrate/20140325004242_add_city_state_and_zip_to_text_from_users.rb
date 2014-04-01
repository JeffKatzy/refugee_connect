class AddCityStateAndZipToTextFromUsers < ActiveRecord::Migration
  def change
    add_column :text_from_users, :city, :string
    add_column :text_from_users, :state, :string
    add_column :text_from_users, :zip, :string
  end
end
