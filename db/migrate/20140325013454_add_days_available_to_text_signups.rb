class AddDaysAvailableToTextSignups < ActiveRecord::Migration
  def change
    add_column :text_signups, :days_available, :string
  end
end
