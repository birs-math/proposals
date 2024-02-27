# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProposalFiltersQuery do
  let(:params) do
    { workshop_year: '', keywords: '', proposal_type: '', location: '', outcome: '', status: [], subject_area: [] }
  end

  let(:current_year) { Time.zone.today.year }
  let(:next_year) { current_year + 1.year }

  let(:five_day_workshop) { create(:proposal_type, name: '5 Day Workshop') }
  let(:two_day_workshop) { create(:proposal_type, name: '2 Day Workshop') }

  let(:rejected) { 'Rejected' }
  let(:approved) { 'Approved' }

  let(:birs) { create(:location, name: 'BIRS') }
  let(:cmo) { create(:location, name: 'CMO') }

  let(:draft) { :draft }
  let(:initial_review) { :initial_review }

  let(:first_subject) { create(:subject) }
  let(:second_subject) { create(:subject) }

  describe '#find' do
    subject(:query) { described_class.new(Proposal.all).find(**params) }

    before do
      create(:proposal, title: 'Test title', year: current_year, proposal_type: five_day_workshop, locations: [cmo],
                        outcome: nil, status: draft, subject: first_subject)
      create(:proposal, year: current_year, proposal_type: five_day_workshop, locations: [cmo],
                        outcome: rejected, status: draft, subject: second_subject)
      create(:proposal, year: next_year, proposal_type: five_day_workshop, locations: [birs],
                        outcome: nil, status: initial_review, subject: first_subject)

      create(:proposal, year: current_year, proposal_type: two_day_workshop, locations: [cmo],
                        outcome: nil, status: initial_review, subject: second_subject)
      create(:proposal, year: current_year, proposal_type: five_day_workshop, locations: [birs],
                        outcome: approved, status: draft, subject: first_subject)
      create(:proposal, title: 'For testing purposes', year: next_year, proposal_type: two_day_workshop,
                        locations: [cmo], outcome: nil, status: draft, subject: second_subject)

      create_list(
        :proposal, 5,
        year: current_year + 2,
        proposal_type: create(:proposal_type, name: 'Focused Research Groups'),
        locations: [create(:location)],
        outcome: 'Declined',
        status: :submitted,
        subject: create(:subject)
      )
    end

    describe '#workshop_year' do
      context 'when current year' do
        let(:params) { { workshop_year: current_year } }

        it { expect(query.count).to eq(4) }
      end

      context 'when next year' do
        let(:params) { { workshop_year: next_year } }

        it { expect(query.count).to eq(2) }
      end
    end

    describe '#keywords' do
      let(:params) { { keywords: 'test' } }

      it { expect(query.count).to eq(2) }
    end

    describe '#proposal_type' do
      context 'when 5 Day Workshop' do
        let(:params) { { proposal_type: five_day_workshop.name } }

        it { expect(query.count).to eq(4) }
      end

      context 'when 2 Day Workshop' do
        let(:params) { { proposal_type: two_day_workshop.name } }

        it { expect(query.count).to eq(2) }
      end
    end

    describe '#location' do
      context 'when BIRS' do
        let(:params) { { location: birs.id } }

        it { expect(query.count).to eq(2) }
      end

      context 'when CMO' do
        let(:params) { { location: cmo.id } }

        it { expect(query.count).to eq(4) }
      end
    end

    describe '#outcome' do
      context 'when Rejected' do
        let(:params) { { outcome: rejected } }

        it { expect(query.count).to eq(1) }
      end

      context 'when Approved' do
        let(:params) { { outcome: approved } }

        it { expect(query.count).to eq(1) }
      end
    end

    describe 'status' do
      context 'when Draft' do
        let(:params) { { status: [draft] } }

        it { expect(query.count).to eq(4) }
      end

      context 'when Initial Review' do
        let(:params) { { status: [initial_review] } }

        it { expect(query.count).to eq(2) }
      end

      context 'when Draft and Initial Review' do
        let(:params) { { status: [draft, initial_review] } }

        it { expect(query.count).to eq(6) }
      end
    end

    describe '#subject_area' do
      context 'when first subject' do
        let(:params) { { subject_area: [first_subject.id] } }

        it { expect(query.count).to eq(3) }
      end

      context 'when second subject' do
        let(:params) { { subject_area: [second_subject.id] } }

        it { expect(query.count).to eq(3) }
      end

      context 'when first and second subjects' do
        let(:params) { { subject_area: [first_subject.id, second_subject.id] } }

        it { expect(query.count).to eq(6) }
      end
    end

    describe 'all params at once' do
      let(:params) do
        {
          workshop_year: current_year,
          keywords: '',
          proposal_type: five_day_workshop.name,
          location: birs.id,
          outcome: '',
          status: [draft],
          subject_area: [first_subject.id]
        }
      end

      it { expect(query.count).to eq(1) }
    end
  end
end
