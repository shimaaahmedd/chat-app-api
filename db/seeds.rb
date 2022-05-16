puts "Starting seeding ... "
password = 'password123'
10.times do |n|
    first_name = Faker::Name.male_first_name
    last_name = Faker::Name.last_name
    email = Faker::Internet.email 

    user = User.create!(
        first_name: first_name,
        last_name: last_name,
        email:email,
        password: password,
    )
    user.save

end

puts "Made users"