class CreateSpecificOpenings < ActiveRecord::Migration
  def change
    create_table :specific_openings do |t|
      t.integer :user_id
      t.integer :opening_id
      t.integer :appointment_id
      t.datetime :scheduled_for
      t.string :status

      t.timestamps
    end
  end
end
