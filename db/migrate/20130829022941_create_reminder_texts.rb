class CreateReminderTexts < ActiveRecord::Migration
  def change
    create_table :reminder_texts do |t|
      t.integer :appointment_id
      t.datetime :time
      t.integer :user_id
      t.string :reminder_type

      t.timestamps
    end
  end
end
