require 'rails_helper'

RSpec.describe InvitesHelper, type: :helper do
  let(:proposal_type) { create(:proposal_type, participant: 2, co_organizer: 1) }
  let(:proposal) { create(:proposal, proposal_type: proposal_type) }
  let(:invite) { create(:invite, proposal: proposal, invited_as: "Participant", status: :confirmed) }
  let(:invite2) { create(:invite, proposal: proposal, invited_as: "Organizer", status: :confirmed) }

  describe '#invite_statuses' do
    let(:statuses) { [%w[Pending pending], %w[Confirmed confirmed], %w[Cancelled cancelled], %w[Declined declined]] }
    it 'returns invite statuses' do
      expect(invite_statuses).to eq(statuses)
    end
  end

  describe '#invite_responses' do
    let(:responses) { [%w[Yes yes], %w[Maybe maybe], %w[No no]] }

    it 'returns invite responses' do
      expect(invite_responses).to eq(responses)
    end
  end

  # describe '#max_invitations' do
  #   it 'returns true if confirmed max invitations not reached' do
  #     expect(max_invitations(proposal, "Participant")).to be_truthy
  #   end

  #   it 'returns false because confirmed max invitations reached' do
  #     invite2
  #     expect(max_invitations(proposal, "Organizer")).to be_falsey
  #   end
  # end

  describe '#invited_role' do
    it 'returns participate role ' do
      expect(invited_role(invite)).to eq('participate in')
    end

    it 'returns organizer role ' do
      expect(invited_role(invite2)).to eq("be a supporting organizer for")
    end
  end

  describe '#confirmed_minimum_participants' do
    it 'returns true if no of participant reached to 10' do
      expect(confirmed_minimum_participants(proposal)).to be_falsey
    end
  end

  describe '#get_affiliation' do
    it 'returns true if no of participant reached to 10' do
      invite.person.update(affiliation: "Test Affiliation")
      expect(get_affiliation(invite)).to be_a String
      expect(get_affiliation(invite)).to eq "Test Affiliation"
    end
  end
end
