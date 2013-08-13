class CreateCallToUsers < ActiveRecord::Migration
  def change
    create_table :call_to_users do |t|
      t.integer :tutor_id
      t.integer :tutee_id
      t.datetime :begin_time
      t.datetime :end_time

      t.timestamps
    end
  end
end
