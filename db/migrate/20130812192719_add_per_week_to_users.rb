class AddPerWeekToUsers < ActiveRecord::Migration
  def change
    add_column :users, :per_week, :integer
  end
end
