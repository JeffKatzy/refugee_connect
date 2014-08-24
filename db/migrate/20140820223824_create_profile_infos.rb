class CreateProfileInfos < ActiveRecord::Migration
  def change
    create_table :profile_infos do |t|
      t.integer :user_id
      t.string :age
      t.text :interests
      t.text :english_focus

      t.timestamps
    end
  end
end
