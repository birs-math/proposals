# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DemographicDataPresenter do
  let(:proposal_ids) { [first_proposal.id, second_proposal.id] }

  let(:first_proposal) { create(:proposal, :with_organizers) }
  let(:second_proposal) { create(:proposal, :with_organizers) }

  let(:demographic_result_one) do
    {
      'stem' => 'Yes',
      'gender' => 'Male',
      'gender_other' => 'Undefined',
      'community' => 'Yes',
      'ethnicity' => 'White',
      'ethnicity_other' => '',
      'disability' => 'Yes',
      'minorities' => 'No',
      'citizenships' => 'Canada',
      'citizenships_other' => '',
      'underRepresented' => 'No',
      'indigenous_person' => 'Yes',
      'academic_status' => 'Software Developer',
      'indigenous_person_yes' => %w[Metis Native]
    }
  end

  let(:demographic_result_two) do
    {
      'stem' => 'No',
      'gender' => 'Female',
      'gender_other' => 'Undefined',
      'community' => 'No',
      'ethnicity' => 'Black',
      'ethnicity_other' => '',
      'disability' => 'No',
      'minorities' => 'Yes',
      'citizenships' => 'USA',
      'citizenships_other' => '',
      'underRepresented' => 'Yes',
      'indigenous_person' => 'No',
      'academic_status' => 'Software Engineer',
      'indigenous_person_yes' => []
    }
  end

  def create_person(demographic_result = demographic_result_one)
    create(:person,
           demographic_data: create(:demographic_data, result: demographic_result),
           academic_status: 'Phd',
           other_academic_status: 'Bachelor')
  end

  def create_invite(person, proposal)
    create(:invite,
           person: person,
           status: :confirmed,
           response: :yes,
           invited_as: 'Participant',
           firstname: person.firstname,
           lastname: person.lastname,
           email: person.email,
           proposal: proposal)
  end

  before do
    create_invite(create_person, first_proposal)
    create_invite(create_person(demographic_result_two), first_proposal)

    create_invite(create_person, second_proposal)
    create_invite(create_person(demographic_result_two), second_proposal)
  end

  describe '#responses' do
    subject(:demographic_responses) { described_class.new(proposal_ids).responses(*keys, source: source) }
    let(:source) { :demographic_data }

    before do
      create_list(:proposal, 2, :with_participants, :with_organizers)
    end

    describe 'stem' do
      let(:keys) { %w[stem] }

      it { expect(demographic_responses).to eq({ 'No' => 2, 'Yes' => 2 }) }
    end

    describe 'gender, gender_other' do
      let(:keys) { %w[gender gender_other] }

      it { expect(demographic_responses).to eq({ 'Male' => 2, 'Female' => 2, 'Undefined' => 4 }) }
    end

    describe 'academic_status, other_academic_status' do
      let(:keys) { %w[academic_status other_academic_status] }
      let(:source) { :person }

      it { expect(demographic_responses).to eq({ 'Phd' => 4, 'Bachelor' => 4 }) }
    end

    describe 'indigenous_person, indigenous_person_yes' do
      let(:keys) { %w[indigenous_person indigenous_person_yes] }

      it { expect(demographic_responses).to eq({ 'No' => 2, 'Yes' => 2, 'Metis' => 2, 'Native' => 2 }) }
    end

    context 'when empty result' do
      let(:demographic_result_one) do
        {
          'stem' => '',
          'gender' => '',
          'gender_other' => '',
          'community' => '',
          'ethnicity' => '',
          'ethnicity_other' => 'Other',
          'disability' => '',
          'minorities' => '',
          'citizenships' => '',
          'citizenships_other' => '',
          'underRepresented' => '',
          'indigenous_person' => '',
          'academic_status' => '',
          'indigenous_person_yes' => []
        }
      end

      let(:keys) { %w[ethnicity ethnicity_other] }

      it 'omits responses' do
        expect(demographic_responses).to eq({ 'Black' => 2 })
      end
    end

    context 'when result is nil' do
      let(:demographic_result_one) { {} }
      let(:keys) { %w[ethnicity ethnicity_other] }

      it { expect(demographic_responses).to eq({ 'Black' => 2 }) }
    end
  end
end