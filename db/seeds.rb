# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

unless Person.find_by(email: 'john.doe@gmail.com')
  Person.create!(firstname: 'John', lastname: 'Doe', email: 'john.doe@gmail.com', affiliation: 'BIRS',
                 deceased: false, retired: true, biography: 'Banff International Research Station')
end

Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].sort.each do |seed|
  load seed
end
