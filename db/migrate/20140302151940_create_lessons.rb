class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.text :name
      t.text :description
      t.text :objectives

      t.timestamps
    end
  end
end
