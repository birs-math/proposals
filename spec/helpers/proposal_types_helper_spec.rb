require 'rails_helper'

RSpec.describe ProposalTypesHelper, type: :helper do
  describe '#list proposal locations' do
    let(:proposal_type) { create(:proposal_type, locations: []) }

    it 'returns '' if locations are empty' do
      expect(list_proposal_locations(proposal_type)).to eq('')
    end
  end

  describe '#list proposal locations' do
    let(:location) { create(:location) }
    let(:proposal_type) { create(:proposal_type, locations: [location]) }

    it 'returns name if locations present' do
      expect(list_proposal_locations(proposal_type)).to eq(location.name)
    end
  end
end
