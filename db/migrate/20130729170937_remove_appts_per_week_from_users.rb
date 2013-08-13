class RemoveApptsPerWeekFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :appts_per_week
  end

  def down
    add_column :users, :appts_per_week, :string
  end
end
