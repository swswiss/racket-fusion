class ChangeAgeToDatetimeInUsers < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :date_of_birth, :datetime
    User.reset_column_information

    # Migrate data from old 'age' column to new 'date_of_birth' column
    User.find_each do |user|
      user.update(date_of_birth: user.age)
    end

    remove_column :users, :age
  end

  def down
    add_column :users, :age, :integer
    User.reset_column_information

    # Migrate data from old 'date_of_birth' column to new 'age' column
    User.find_each do |user|
      user.update(age: user.date_of_birth)
    end

    remove_column :users, :date_of_birth
  end
end
