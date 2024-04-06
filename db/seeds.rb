require 'faker'

# User.destroy_all
usernames = []
emails = []

# Generate unique usernames with first name and last name and corresponding unique emails
while usernames.length < 100 do
  first_name = Faker::Name.first_name.downcase
  last_name = Faker::Name.last_name.downcase
  username = "#{first_name} #{last_name}"
  email = "#{first_name}#{last_name}@example.com"
  
  # Check if username and email are unique
  unless usernames.include?(username) || emails.include?(email)
    usernames << username
    emails << email
  end
end

# Loop through each username and create a user
usernames.each_with_index do |username, index|
  email = emails[index]
  display_name = username
  image_profile = "man"
  points = 20
  phone = "3243254325"
  level = "Medium"
  password = "federer"
  
  User.create(
    email: email,
    username: username,
    display_name: display_name,
    image_profile: image_profile,
    admin: nil,
    points: points,
    rank: nil,
    phone: phone,
    level: level,
    date_of_birth: nil,
    password: password,
    password_confirmation: password,
    status: 0
  )
end
