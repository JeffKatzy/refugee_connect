class CreateBookpages < ActiveRecord::Migration
  def change
    create_table :bookpages do |t|
      t.string :title
      t.integer :page_number
      t.string :image

      t.timestamps
    end
  end
end
