FactoryBot.define do
  factory :proposal_type do
    name { '5 Day Workshop' }
    year { '2021,2022,2023' }
    code { Faker::Code.npi }
    open_date { Time.current.to_date }
    closed_date { Time.current.to_date + 1.week }
    participant { 2 }
    co_organizer { 3 }
    participant_description { Faker::Lorem.paragraph }
    organizer_description { Faker::Lorem.paragraph }
    max_no_of_preferred_dates { 2 }
    min_no_of_preferred_dates { 2 }
    max_no_of_impossible_dates { 2 }
    min_no_of_impossible_dates { 2 }
    capacity { 42 }
  end
end
