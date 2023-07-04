# spec/factories/people.rb
# require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  sequence(:firstname) { |n| "#{n}-#{Faker::Name.first_name}" }
  sequence(:lastname) { Faker::Name.last_name }
  sequence(:country) { set_valid_country }
  sequence(:email) { |n| "person-#{n}@" + Faker::Internet.domain_name }

  factory :person do |f|
    f.firstname
    f.lastname
    f.email
    f.affiliation { Faker::University.name }
    f.url { Faker::Internet.url }
    f.research_areas { Faker::Lorem.words(number: 4).join(', ') }
    f.biography { Faker::Lorem.paragraph }
    f.retired { false }
    f.deceased { false }
    f.country { set_valid_country }
    f.academic_status { Faker::Educator.degree }
    f.other_academic_status { Faker::Educator.degree }
    f.first_phd_year { Date.current.year - 5 }
  end

  after(:create) do |person|
    if person.instance_of?(Person) && person.demographic_data.nil? # person is sometimes not a Person object(!?)
      person.demographic_data = create(:demographic_data, person: person)
    end
  end

  trait :with_proposals do
    after(:create) do |person|
      organizer = create(:role, name: 'lead_organizer')
      create_list(:proposal, 3).each do |proposal|
        proposal.create_organizer_role(person, organizer)
        3.times do
          create(:invite, proposal: proposal, status: 'confirmed',
                          invited_as: 'Organizer')
        end
      end
    end
  end
end
