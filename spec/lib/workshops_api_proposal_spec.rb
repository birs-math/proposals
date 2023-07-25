require 'rails_helper'

RSpec.describe WorkshopsApiProposal do
  subject(:workshop_api_proposal) { WorkshopsApiProposal.new(proposal) }
  let(:proposal) { create(:proposal, :with_organizers, :submission) }

  describe 'keys' do
    it { expect(workshop_api_proposal.event).to include(:api_key, :updated_by, :event, :memberships) }
  end
end
