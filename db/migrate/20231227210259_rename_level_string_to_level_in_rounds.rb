class RenameLevelStringToLevelInRounds < ActiveRecord::Migration[6.1]
  def change
    rename_column :rounds, :level_string, :level
  end
end
