class RenameTypeToKindInMatches < ActiveRecord::Migration[6.1]
  def change
    rename_column :matches, :type, :kind
  end
end
