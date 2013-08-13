class CreateAvailabilityManagers < ActiveRecord::Migration
  def change
    create_table :availability_managers do |t|
      t.integer :user_id
      t.integer :per_week
      t.text :schedule_hash

      t.timestamps
    end
  end
end
