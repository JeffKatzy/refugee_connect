class CreateConfirmations < ActiveRecord::Migration
  def change
    create_table :confirmations do |t|
      t.integer :user_id
      t.integer :specific_opening_id
      t.boolean :confirmed

      t.timestamps
    end
  end
end
