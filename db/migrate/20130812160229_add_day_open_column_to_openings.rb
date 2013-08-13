class AddDayOpenColumnToOpenings < ActiveRecord::Migration
  def change
  	remove_column :openings, :day_open
    add_column :openings, :day_open, :string
  end
end
