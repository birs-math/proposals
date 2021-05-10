FactoryBot.define do
  factory :proposal_form do
    status { %w[draft active].sample }
    title { Faker::Lorem.paragraph(sentence_count: 2) }
    
    association :proposal_type, factory: :proposal_type, strategy: :create
    association :created_by, factory: :user, strategy: :create
    association :updated_by, factory: :user, strategy: :create
  end
end
