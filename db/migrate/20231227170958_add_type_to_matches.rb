class AddTypeToMatches < ActiveRecord::Migration[6.1]
  def change
    add_column :matches, :type, :string
  end
end
