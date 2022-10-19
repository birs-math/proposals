FactoryBot.define do
  factory :schedule do
    schedule_run_id { 12 }
    week { 23 }
    case_num { 34 }
    hmc_score { 43 }
    proposal { Faker::Lorem.paragraph }

    association :schedule_run, factory: :schedule_run, strategy: :create
  end
end
