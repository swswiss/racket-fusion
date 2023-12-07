class CreateTournaments < ActiveRecord::Migration[6.1]
  def change
    create_table :tournaments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :description
      t.boolean :status
      t.integer :max_lvl1
      t.integer :max_lvl2
      t.integer :max_lvl3
      t.integer :max_lvl4

      t.timestamps
    end
  end
end
