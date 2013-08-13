class AddApptsPerWeekToUsers < ActiveRecord::Migration
  def change
    add_column :users, :appts_per_week, :integer
    add_column :users, :active, :boolean
  end
end
