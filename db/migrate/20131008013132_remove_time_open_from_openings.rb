class RemoveTimeOpenFromOpenings < ActiveRecord::Migration
  def up
    remove_column :openings, :time_open
    add_column :openings, :time_open, :string
  end

  def down
    add_column :openings, :time_open, :string
  end
end
