class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :comment_text
      t.integer :tutor_id
      t.integer :user_assignment_id

      t.timestamps
    end
  end
end
