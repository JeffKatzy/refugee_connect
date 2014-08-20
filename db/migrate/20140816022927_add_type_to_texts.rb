class AddTypeToTexts < ActiveRecord::Migration
  def change
    add_column :texts, :type, :string
  end
end
