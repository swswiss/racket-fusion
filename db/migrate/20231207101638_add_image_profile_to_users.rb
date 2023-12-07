class AddImageProfileToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :image_profile, :string
  end
end
