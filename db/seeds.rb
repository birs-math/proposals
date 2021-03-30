# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

location = Location.create!(name: 'canada')
location.proposal_types.create!(name: '2D workshop')
location.proposal_types.create!(name: '3D workshop')
location.proposal_types.create!(name: '5D workshop')
