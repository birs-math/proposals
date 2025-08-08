require 'rails_helper'

RSpec.describe ExpireInvitationsJob, type: :job do
  let(:proposal) { create(:proposal) }
  let(:lead_organizer) { create(:person) }
  let!(:expired_invite) { create(:invite, proposal: proposal, status: 'pending', deadline_date: 1.day.ago) }
  let!(:active_invite) { create(:invite, proposal: proposal, status: 'pending', deadline_date: 1.day.from_now) }

  before do
    proposal.update!(lead_organizer: lead_organizer)
  end

  describe '#perform' do
    it 'expires overdue invitations' do
      expect {
        described_class.perform_now
      }.to change { expired_invite.reload.status }.from('pending').to('expired')
    end

    it 'does not expire active invitations' do
      expect {
        described_class.perform_now
      }.not_to change { active_invite.reload.status }
    end

    it 'logs the process' do
      expect(Rails.logger).to receive(:info).with(/Starting ExpireInvitationsJob/)
      expect(Rails.logger).to receive(:info).with(/Expired 1 invitations/)
      expect(Rails.logger).to receive(:info).with(/Completed ExpireInvitationsJob/)

      described_class.perform_now
    end

    context 'when no invitations to expire' do
      before do
        expired_invite.update!(status: 'confirmed')
      end

      it 'logs no invitations to expire' do
        expect(Rails.logger).to receive(:info).with(/No invitations to expire/)

        described_class.perform_now
      end
    end
  end
end
