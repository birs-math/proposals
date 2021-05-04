# spec/factories/people.rb
require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  sequence(:firstname) { |n| "#{n}-#{Faker::Name.first_name}" }
  sequence(:lastname) { Faker::Name.last_name }
  sequence(:email) { |n| "person-#{n}@" + Faker::Internet.domain_name }

  factory :person do |f|
    f.firstname
    f.lastname
    f.email
    f.affiliation { Faker::University.name }
    f.url { Faker::Internet.url }
    f.research_areas { Faker::Lorem.words(number: 4).join(', ') }
    f.biography { Faker::Lorem.paragraph }
    f.retired { %w[true false].sample }
    f.deceased { %w[true false].sample }
  end
end
