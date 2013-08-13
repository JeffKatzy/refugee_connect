class CreateTextToUsers < ActiveRecord::Migration
  def change
    create_table :text_to_users do |t|
      t.integer :user_id
      t.datetime :time
      t.text :body

      t.timestamps
    end
  end
end
