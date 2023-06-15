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
    association :subject, factory: :subject, strategy: :create
  end

  trait :with_organizers do
    after(:create) do |proposal|
      lead_role = create(:role, name: 'lead_organizer')
      proposal.create_organizer_role(create(:person), lead_role)

      3.times do
        person = create(:person)
        create(:invite, proposal: proposal, status: 'confirmed',
                        invited_as: 'Organizer', response: 'yes',
                        firstname: person.firstname, lastname: person.lastname,
                        email: person.email, person: person)
      end
    end
  end

  trait :submission do
    after(:create) do |proposal|
      proposal.ams_subjects << create_list(:ams_subject, 2)
      proposal.locations << create(:location)
      create(:invite, invited_as: 'Organizer', response: :yes, status: :confirmed, proposal: proposal)

      proposal.is_submission = true
      proposal.save
    end
  end
end
