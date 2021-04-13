FactoryBot.define do
  factory :role_privilege do
    association :role, factory: :role
  end
end
