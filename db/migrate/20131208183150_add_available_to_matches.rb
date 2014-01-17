class AddAvailableToMatches < ActiveRecord::Migration
  def change
    add_column :matches, :available, :boolean
  end
end
