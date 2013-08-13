class CreateAvailabilities < ActiveRecord::Migration
  def change
    create_table :availabilities do |t|
      t.integer :user_id
      t.text :schedule
      t.integer :per_week

      t.timestamps
    end
  end
end
