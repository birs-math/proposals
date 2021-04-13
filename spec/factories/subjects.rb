FactoryBot.define do
  factory :subject do
    code { Faker::Code.npi }
    title { Faker::Book.title }

    association :subject_category, factory: :subject_category
  end
end
