class AddScoreToMatches < ActiveRecord::Migration[6.1]
  def change
    add_column :matches, :score, :string
  end
end
