FactoryBot.define do
  factory :proposal do
    submission do
      json = Faker::Json.shallow_json(width: 3, options: { key: 'Name.first_name', value: 'Name.last_name' })
      Faker::Json.add_depth_to_json(json: json, width: 2, options: { key: 'Name.first_name', value: 'Name.last_name' })
    end

    association :location, factory: :location, strategy: :create
    association :proposal_type, factory: :proposal_type, strategy: :create
  end
end
