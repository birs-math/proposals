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

    it 'sends notification emails for expired invitations' do
      expect(InvitationExpirationMailer).to receive(:with).with(
        proposal: proposal,
        expired_invitations: [expired_invite],
        lead_organizer: lead_organizer
      ).and_return(double('mailer').tap { |m| allow(m).to receive(:expiration_notification).and_return(double('mail').tap { |mail| allow(mail).to receive(:deliver_later) } }) }

      described_class.perform_now
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

    context 'when notification fails' do
      before do
        allow(InvitationExpirationMailer).to receive(:with).and_raise(StandardError.new('Email failed'))
      end

      it 'logs the error but continues processing' do
        expect(Rails.logger).to receive(:error).with(/Failed to send expiration notification/)

        expect { described_class.perform_now }.not_to raise_error
      end
    end
  end
end
