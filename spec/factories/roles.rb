FactoryBot.define do
  factory :role do
    name { 'Admin' }
    role_type { :staff_role }
  end
end
