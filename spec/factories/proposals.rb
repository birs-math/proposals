FactoryBot.define do
  factory :proposal do
    year { Date.current.year.to_i + 2 }
    title { Faker::Lorem.sentence(word_count: 4) }
    sequence(:code) { |n| "#{rand(99)}w5#{rand(99)}#{n}" }

    submission do
      json = Faker::Json.shallow_json(width: 3, options: { key: 'Name.first_name', value: 'Name.last_name' })
      Faker::Json.add_depth_to_json(json: json, width: 2, options: { key: 'Name.first_name', value: 'Name.last_name' })
    end

    association :proposal_type, factory: :proposal_type, strategy: :create
    association :proposal_form, factory: :proposal_form, strategy: :create
  end
end
