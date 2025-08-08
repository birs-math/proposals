require 'rails_helper'

RSpec.describe InvitationExpirationMailer, type: :mailer do
  let(:proposal) { create(:proposal) }
  let(:lead_organizer) { create(:person, email: 'organizer@example.com') }
  let(:expired_organizer_invite) { create(:invite, proposal: proposal, invited_as: 'Organizer', status: 'expired') }
  let(:expired_participant_invite) { create(:invite, proposal: proposal, invited_as: 'Participant', status: 'expired') }
  let(:expired_invitations) { [expired_organizer_invite, expired_participant_invite] }

  before do
    proposal.update!(lead_organizer: lead_organizer)
  end

  describe 'expiration_notification' do
    let(:mail) do
      InvitationExpirationMailer.with(
        proposal: proposal,
        expired_invitations: expired_invitations,
        lead_organizer: lead_organizer
      ).expiration_notification
    end

    it 'renders the headers' do
      expect(mail.subject).to eq("Invitations Expired - #{proposal.title}")
      expect(mail.to).to eq([lead_organizer.email])
      expect(mail.from).to be_present
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Invitations Expired')
      expect(mail.body.encoded).to match(proposal.title)
      expect(mail.body.encoded).to match(lead_organizer.fullname)
    end

    it 'includes expired organizer information' do
      expect(mail.body.encoded).to match('Supporting Organizers')
      expect(mail.body.encoded).to match(expired_organizer_invite.firstname)
      expect(mail.body.encoded).to match(expired_organizer_invite.email)
    end

    it 'includes expired participant information' do
      expect(mail.body.encoded).to match('Participants')
      expect(mail.body.encoded).to match(expired_participant_invite.firstname)
      expect(mail.body.encoded).to match(expired_participant_invite.email)
    end

    it 'includes available spots information' do
      expect(mail.body.encoded).to match('Available Spots')
      expect(mail.body.encoded).to match('Supporting Organizers')
      expect(mail.body.encoded).to match('Participants')
    end

    context 'when no expired organizers' do
      let(:expired_invitations) { [expired_participant_invite] }

      it 'does not include organizer section' do
        expect(mail.body.encoded).not_to match('Supporting Organizers')
      end
    end

    context 'when no expired participants' do
      let(:expired_invitations) { [expired_organizer_invite] }

      it 'does not include participant section' do
        expect(mail.body.encoded).not_to match('Participants')
      end
    end
  end
end
