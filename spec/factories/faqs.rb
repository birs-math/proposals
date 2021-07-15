FactoryBot.define do
  factory :faq do
    question { Faker::Lorem.paragraph }
    answer { Faker::Lorem.paragraph }
  end
end
