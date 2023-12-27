class CreateRounds < ActiveRecord::Migration[6.1]
  def change
    create_table :rounds do |t|
      t.integer :tournament_id
      t.string :level_string

      t.timestamps
    end
  end
end
