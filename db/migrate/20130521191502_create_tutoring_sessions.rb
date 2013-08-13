class CreateTutoringSessions < ActiveRecord::Migration
  def change
    create_table :tutoring_sessions do |t|
      t.integer :tutor_id
      t.integer :tutee_id
      t.string :status
      t.datetime :time
      t.integer :start_page
      t.integer :finish_page

      t.timestamps
    end
  end
end
