class CreateTextSignups < ActiveRecord::Migration
  def change
    create_table :text_signups do |t|
      t.string :status
      t.integer :user_id

      t.timestamps
    end
  end
end
