FactoryBot.define do
  factory :user do |_u|
    email { Faker::Internet.email }
    password { Faker::Internet.password }
  end
end
