class CreateOpenings < ActiveRecord::Migration
  def change
    create_table :openings do |t|
      t.integer :user_id
      t.integer :day_open
      t.integer :time_open

      t.timestamps
    end
  end
end
