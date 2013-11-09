class AddTimeToOpenings < ActiveRecord::Migration
  def change
    add_column :openings, :time, :datetime
  end
end
