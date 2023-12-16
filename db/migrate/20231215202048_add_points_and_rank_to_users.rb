class AddPointsAndRankToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :points, :integer, default: 0
    add_column :users, :rank, :integer
  end
end
