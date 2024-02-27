FactoryBot.define do
  factory :user do |f|
    association :person, factory: :person
    password ||= Faker::Internet.password(min_length: 12)

    f.email { Faker::Internet.email }
    f.password { password }
    f.password_confirmation { password }
    f.confirmed_at { Time.current }

    trait :with_privilege do
      after(:create) do |user, options|
        user_role = create(:user_role, user: user)
        privilege_name = options[:privilege_name] || 'SubmitProposalsController'
        create(:role_privilege, permission_type: 'Manage', privilege_name: privilege_name, role: user_role.role)
      end
    end
  end
end
