FactoryBot.define do
  factory :proposal_form do
    status { %w[draft active].sample }

    association :proposal_type, factory: :proposal_type, strategy: :create
  end
end
