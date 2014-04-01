class AddCountryToText < ActiveRecord::Migration
  def change
    add_column :text_from_users, :country, :string
  end
end
