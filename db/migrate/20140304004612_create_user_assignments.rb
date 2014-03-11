class CreateUserAssignments < ActiveRecord::Migration
  def change
    create_table :user_assignments do |t|
      t.integer :user_id
      t.integer :assignment_id
      t.string :status

      t.timestamps
    end
  end
end
