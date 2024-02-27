require 'rails_helper'

RSpec.describe InviteMailer, type: :mailer do
  Proposals::Application.load_tasks

  before(:all) do
    Rake::Task['birs:liquid_email_templates'].invoke
  end

  describe '#invited_as_text' do
    context 'when invite is organizer' do
      let(:invite) { create(:invite, invited_as: 'Organizer') }

      it "returns a Supporting Organizer for" do
        expect(invite.reload.invited_as.downcase).to eq("organizer")
      end
    end

    context 'when invite is participant' do
      let(:invite) { create(:invite, invited_as: 'Participant') }

      it "returns a Participant in" do
        expect(invite.reload.invited_as.downcase).to eq("participant")
      end
    end
  end

  describe 'invite_email' do
    let(:proposal) { create(:proposal, :with_organizers) }
    let(:invite) { create(:invite, proposal: proposal) }
    let(:person) { create(:person, invite: invite) }
    let(:email) { InviteMailer.with(invite: invite).invite_email }

    context 'when lead organizer is present' do
      let(:email) { InviteMailer.with(invite: invite, lead_organizer_copy: true).invite_email }

      it { expect(email.subject).to eq("BIRS Proposal: Invitation for #{invite.humanize_invited_as}") }

      it 'sends to lead organizer' do
        expect(email.to).to eq([proposal.lead_organizer.email])
      end
    end

    context 'when lead organizer is not present' do
      it { expect(email.subject).to eq("BIRS Proposal: Invitation for #{invite.humanize_invited_as}") }

      it 'sends to participant' do
        expect(email.to).to eq([invite.email])
      end
    end

    context 'rendering liquid' do
      before do
        email.deliver_now
      end

      let(:delivery) { ActionMailer::Base.deliveries.last }

      it { expect(delivery.html_part.body.to_s).to include(proposal.title) }
    end
  end

  describe 'invite_acceptance' do
    let(:proposal) { create(:proposal, :with_organizers) }
    let(:invite) { create(:invite, proposal: proposal) }
    let(:email) { InviteMailer.with(invite: invite, organizers: nil).invite_acceptance }

    context 'when organizers are present' do
      let(:invites) { create_list(:invite, 3, invited_as: 'Organizer', status: 'confirmed', response: 'yes') }
      let(:organizers) { invites.map(&:person).map(&:fullname).join(', ') }
      let(:email) { InviteMailer.with(invite: invite, organizers: organizers).invite_acceptance }
      it "sends an invite acceptance email" do
        expect(email.subject).to eq("BIRS Proposal Confirmation of Interest")
      end
    end

    it "sends an invite acceptance email" do
      expect(email.subject).to eq("BIRS Proposal Confirmation of Interest")
    end

    context 'rendering liquid' do
      before do
        email.deliver_now
      end

      let(:delivery) { ActionMailer::Base.deliveries.last }

      it { expect(delivery.html_part.body.to_s).to include(invite.person.fullname) }
    end
  end

  describe 'invite_decline' do
    let(:proposal) { create(:proposal) }
    let(:invite) { create(:invite, proposal: proposal) }
    let(:person) { create(:person, invite: invite) }
    let(:email) { InviteMailer.with(invite: invite).invite_decline }

    it "sends an invite decline email" do
      expect(email.subject).to eq("Invite Declined")
    end
  end

  describe 'invite_reminder' do
    let(:proposal) { create(:proposal) }
    let(:invite) { create(:invite, proposal: proposal) }
    let(:person) { create(:person, invite: invite) }
    let(:email) { InviteMailer.with(invite: invite, organizers: nil).invite_reminder }

    context 'when organizers are present' do
      let(:invites) { create_list(:invite, 3, invited_as: 'Organizer', status: 'confirmed', response: 'yes') }
      let(:organizers) { invites.map(&:person).map(&:fullname).join(', ') }
      let(:email) { InviteMailer.with(invite: invite, organizers: organizers).invite_reminder }
      it "sends an invite reminder email" do
        expect(email.subject).to eq("Please Respond – BIRS Proposal Invitation for #{invite.humanize_invited_as}")
      end
    end

    it "sends an invite reminder email" do
      expect(email.subject).to eq("Please Respond – BIRS Proposal Invitation for #{invite.humanize_invited_as}")
    end

    context 'rendering liquid' do
      before do
        email.deliver_now
      end

      let(:delivery) { ActionMailer::Base.deliveries.last }

      it { expect(delivery.html_part.body.to_s).to include(invite.deadline_date.to_date.to_s) }
    end
  end
end
