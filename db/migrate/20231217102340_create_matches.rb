class CreateMatches < ActiveRecord::Migration[6.1]
  def change
    create_table :matches do |t|
      t.string :level
      t.integer :first_player
      t.integer :second_player

      t.timestamps
    end
  end
end
