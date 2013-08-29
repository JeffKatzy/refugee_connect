class RemoveReminderTypeFromReminderTexts < ActiveRecord::Migration
  def change
    remove_column :reminder_texts, :reminder_type
    add_column :reminder_texts, :type, :string
  end
end
