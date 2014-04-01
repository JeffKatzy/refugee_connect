class AddDayMissingTimeToTextSignup < ActiveRecord::Migration
  def change
  	add_column :text_signups, :day_missing_time, :string
  end
end
