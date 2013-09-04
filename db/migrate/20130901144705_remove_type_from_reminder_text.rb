class RemoveTypeFromReminderText < ActiveRecord::Migration
  def change
    remove_column :reminder_texts, :type
    add_column :reminder_texts, :category, :string
  end
end
