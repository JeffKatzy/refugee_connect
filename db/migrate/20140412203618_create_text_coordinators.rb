class CreateTextCoordinators < ActiveRecord::Migration
  def change
    create_table :text_coordinators do |t|
      t.integer :appointment_id
      t.integer :user_id
      t.integer :text_signup_id

      t.timestamps
    end
  end
end
