FactoryBot.define do
  factory :ams_subject do
    code { Faker::Code.npi }
    title { Faker::Book.title }

    association :subject, factory: :subject
  end
end
