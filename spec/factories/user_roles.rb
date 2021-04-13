FactoryBot.define do
  factory :user_role do
    association :user, factory: user
    association :role, factory: role
  end
end
