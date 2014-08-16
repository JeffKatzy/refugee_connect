class CreateTexts < ActiveRecord::Migration
  def change
    create_table :texts do |t|
      t.string :body
      t.integer :user_id
      t.integer :unit_of_work_id
      t.string :unit_of_work_type

      t.timestamps
    end
  end
end
