require "rails_helper"

RSpec.describe ProposalMailer, type: :mailer do
  let(:proposal) { create(:proposal, :with_organizers) }
  let(:proposal_role) { create(:proposal_role, proposal: proposal) }
  let(:organizer) { proposal_role.person.fullname }
  let(:birs_email) do
    create(:birs_email, cc_email: cc_email, bcc_email: bcc_email, subject: 'Staff send emails', proposal: proposal)
  end
  let(:cc_email) { nil }
  let(:bcc_email) { nil }

  before do
    proposal.update(status: :submitted, code: '23w501', title: 'BANFF')
    proposal_role.role.update(name: 'lead_organizer')
  end

  describe 'proposal_submission with submitted status' do
    let(:email) { ProposalMailer.with(proposal: proposal).proposal_submission }

    it "sends an proposal_submission email" do
      expect(email.subject).to eq("BIRS Proposal #{proposal.code}: #{proposal.title}")
    end
  end

  describe 'proposal_submission with nil status' do
    let(:email) { ProposalMailer.with(proposal: proposal).proposal_submission }

    it "sends an proposal_submission email" do
      expect(email.subject).to eq("BIRS Proposal #{proposal.code}: #{proposal.title}")
    end
  end

  describe 'staff_send_emails' do
    let(:email) { ProposalMailer.with(email_data: birs_email).staff_send_emails }

    context "when cc_email and bcc_email are present" do
      let(:cc_email) { 'chris@gmail.com, adamvan.tuyl@gmail.com' }
      let(:bcc_email) { 'chris@mail.com, adamvan.tuyl@mail.com' }

      it do
        expect(email.cc).to eq(cc_email.split(', '))
        expect(email.bcc).to eq(bcc_email.split(', '))
      end
    end

    context "when cc_email is present" do
      let(:cc_email) { 'chris@gmail.com, adamvan.tuyl@gmail.com' }

      it do
        expect(email.cc).to eq(cc_email.split(', '))
        expect(email.bcc).to eq([])
      end
    end

    context "when bcc_email is present" do
      let(:bcc_email) { 'chris@gmail.com, adamvan.tuyl@gmail.com' }

      it do
        expect(email.cc).to eq([])
        expect(email.bcc).to eq(bcc_email.split(', '))
      end
    end

    context "when cc_email and bcc_email are not present" do
      it do
        expect(email.cc).to eq([])
        expect(email.bcc).to eq([])
      end
    end
  end

  describe 'new_staff_send_emails' do
    let(:email) { ProposalMailer.with(email_data: birs_email, organizer: organizer).new_staff_send_emails }

    context "when cc_email and bcc_email are present" do
      let(:cc_email) { 'chris@gmail.com, adamvan.tuyl@gmail.com' }
      let(:bcc_email) { 'chris@mail.co, adamvan.tuyl@mail.co' }

      it do
        expect(email.cc).to eq(cc_email.split(', '))
        expect(email.bcc).to eq(bcc_email.split(', '))
      end
    end

    context "when cc_email is present" do
      let(:cc_email) { 'chris@gmail.com, adamvan.tuyl@gmail.com' }

      it do
        expect(email.cc).to eq(cc_email.split(', '))
        expect(email.bcc).to eq([])
      end
    end

    context "when bcc_email is present" do
      let(:bcc_email) { 'chris@mail.co, adamvan.tuyl@mail.co' }

      it do
        expect(email.cc).to eq([])
        expect(email.bcc).to eq(bcc_email.split(', '))
      end
    end

    context "when cc_email and bcc_email are not present" do
      it do
        expect(email.cc).to eq([])
        expect(email.bcc).to eq([])
      end
    end
  end
end
