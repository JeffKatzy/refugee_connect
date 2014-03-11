class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.text :instructions
      t.integer :lesson_id

      t.timestamps
    end
  end
end
