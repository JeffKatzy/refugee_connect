class CreateTextFromUsers < ActiveRecord::Migration
  def change
    create_table :text_from_users do |t|
      t.text :body
      t.datetime :time
      t.integer :user_id

      t.timestamps
    end
  end
end
