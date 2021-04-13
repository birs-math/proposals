FactoryBot.define do
  factory :location do
    city { Faker::Address.city }
    country { Faker::Address.country }
    code { Faker::Address.country_code }
    name { Faker::Address.full_address }
  end
end
