class AddRoundIdToMatches < ActiveRecord::Migration[6.1]
  def change
    add_reference :matches, :round, null: true, foreign_key: true
  end
end
