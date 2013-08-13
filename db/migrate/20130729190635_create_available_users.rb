class CreateAvailableUsers < ActiveRecord::Migration
  def change
    create_table :available_users do |t|
      t.integer :user_id
      t.datetime :from
      t.datetime :to
      t.boolean :available

      t.timestamps
    end
  end
end
