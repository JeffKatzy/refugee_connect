class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.integer :tutor_id
      t.integer :tutee_id

      t.timestamps
    end
  end
end
