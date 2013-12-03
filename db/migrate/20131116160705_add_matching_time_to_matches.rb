class AddMatchingTimeToMatches < ActiveRecord::Migration
  def change
    add_column :matches, :match_time, :datetime
  end
end
