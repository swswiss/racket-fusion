class ChangeGroupIdToNullableInMatches < ActiveRecord::Migration[6.1]
  def change
    change_column :matches, :group_id, :bigint, null: true
  end
end
