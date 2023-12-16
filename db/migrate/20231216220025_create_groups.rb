class CreateGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :groups do |t|
      t.string :level
      t.integer :tournament_id

      t.timestamps
    end
  end
end
