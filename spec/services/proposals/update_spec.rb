# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Proposals::Update do
  subject(:service_call) { described_class.call(current_user: user, proposal: proposal, params: params) }

  let(:user) { create(:user) }
  let(:proposal) { create(:proposal) }

  let(:params) { { title: 'New title', year: Date.today.year } }

  describe '.call' do
    it 'has no errors' do
      expect(service_call.errors?).to be_falsey
    end

    it 'updates proposal' do
      service_call
      proposal.reload

      expect(proposal.title).to eq(params[:title])
      expect(proposal.year).to eq(params[:year].to_s)
    end

    context 'proposal per type per year limit exceeded' do
      let(:role) { create(:role, name: 'lead_organizer') }
      let(:old_proposal) do
        create(:proposal, proposal_type: proposal.proposal_type, year: params[:year], status: :submitted)
      end

      before do
        create(:proposal_role, proposal: old_proposal, role: role, person: user.person)
      end

      it 'has error' do
        expect(service_call.errors?).to be_truthy
      end

      it 'has error message' do
        expect(service_call.flash_message[:alert])
          .to eq(["Year #{I18n.t('proposals.limit_per_type_per_year', proposal_type: proposal.proposal_type.name)}"])
      end

      it 'updates attributes except year' do
        service_call
        proposal.reload

        expect(proposal.title).to eq(params[:title])
        expect(proposal.year).not_to eq(params[:year])
      end
    end

    context 'when error' do
      before do
        allow_any_instance_of(described_class).to receive(:first_ams_subject_id).and_return(1)
      end

      it 'shows error' do
        expect(service_call.flash_message[:alert]).to eq(['Validation failed: Ams subject must exist'])
      end
    end
  end
end
