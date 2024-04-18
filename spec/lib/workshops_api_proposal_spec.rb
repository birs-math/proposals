require 'rails_helper'

RSpec.describe WorkshopsApiProposal do
  subject(:workshop_api_proposal) { described_class.new(proposal) }

  let(:proposal) { create(:proposal, :with_organizers, :submission) }

  describe '#event' do
    it 'includes necessary keys' do
      expect(workshop_api_proposal.event).to include(:api_key, :updated_by, :event, :memberships)
    end
  end

  describe '#event_data' do
    subject { workshop_api_proposal.event[:event] }

    it 'returns event data' do
      expect(subject).to include(:code, :name, :start_date, :end_date, :event_type,
                                 :location, :press_release, :description, :subjects,
                                 :custom_fields_attributes)
    end

    context 'when proposal has custom fields to export' do
      subject { workshop_api_proposal.event[:event][:custom_fields_attributes] }

      let(:first_proposal_field) do
        create(:proposal_field, statement: 'Press release', description: 'Press release description',
                                proposal_form: proposal.proposal_form, export: true)
      end
      let(:second_proposal_field) do
        create(:proposal_field, statement: 'Objectives', description: 'Objectives description',
                                proposal_form: proposal.proposal_form, export: false)
      end

      before do
        create(:answer, proposal: proposal, proposal_field: first_proposal_field, answer: 'Press release answer')
        create(:answer, proposal: proposal, proposal_field: second_proposal_field, answer: 'Objectives answer')
      end

      it 'returns correct custom fields data size' do
        expect(subject.size).to eq(1)
      end

      it 'returns correct custom fields data' do
        expect(subject.first).to include(:title, :description, :position, :value)
      end

      it 'returns correct value in custom fields attributes' do
        expect(subject.first[:value]).to eq('Press release answer')
      end

      it 'returns correct description in custom fields attributes' do
        expect(subject.first[:description]).to eq(first_proposal_field.description)
      end

      it 'returns correct title in custom fields attributes' do
        expect(subject.first[:title]).to eq(first_proposal_field.statement)
      end
    end

    context 'when proposal has no custom fields to export' do
      it 'returns empty custom fields attributes' do
        expect(subject[:custom_fields_attributes]).to eq([])
      end
    end
  end
end
