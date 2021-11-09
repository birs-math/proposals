require 'rails_helper'

RSpec.describe Email, type: :model do
  it 'has valid factory' do
    expect(build(:birs_email)).to be_valid
  end

  it 'requires a email subject' do
    email = build(:birs_email, subject: '')
    expect(email.valid?).to be_falsey
  end

  it 'requires a email body' do
    email = build(:birs_email, body: '')
    expect(email.valid?).to be_falsey
  end

  describe 'associations' do
    it { should belong_to(:proposal) }
  end

  describe '#update_status' do
    let(:proposal) { create(:proposal) }
    let(:birs_email) { create(:birs_email, proposal: proposal) }
    context 'when status is Revision' do
      before do
        proposal.update(status: 'revision_submitted')
      end
      it '' do
        expect(proposal.reload.status).to eq('revision_submitted')
        expect(birs_email.update_status(proposal, 'Revision')).to be_truthy
      end
    end
    context 'when status is Revision SPC' do
      before do
        proposal.update(status: 'revision_submitted_spc')
      end
      it '' do
        expect(proposal.reload.status).to eq('revision_submitted_spc')
        expect(birs_email.update_status(proposal, 'Revision SPC')).to be_truthy
      end
    end
    context 'when status is Reject' do
      before do
        proposal.update(status: 'decision_pending', outcome: 'rejected')
      end
      it '' do
        expect(proposal.reload.status).to eq('decision_pending')
        expect(proposal.reload.outcome).to eq('rejected')
        expect(birs_email.update_status(proposal, 'Reject')).to be_truthy
      end
    end
    context 'when status is Approval' do
      before do
        proposal.update(status: 'decision_pending', outcome: 'approved')
      end
      it '' do
        expect(proposal.reload.status).to eq('decision_pending')
        expect(proposal.reload.outcome).to eq('approved')
        expect(birs_email.update_status(proposal, 'Approval')).to be_truthy
      end
    end
    context 'when status is Decision' do
      before do
        proposal.update(status: 'decision_pending')
      end
      it '' do
        expect(proposal.reload.status).to eq('decision_pending')
        expect(birs_email.update_status(proposal, 'Decision')).to be_truthy
      end
    end

    it { expect(birs_email.update_status(proposal, 'Draft')).to be_falsey }
  end
end
