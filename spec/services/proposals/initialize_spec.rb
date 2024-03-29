# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Proposals::Initialize do
  subject(:service_call) { described_class.call(current_user: user, proposal_params: params) }

  let(:user) { create(:user) }
  let(:proposal_form) { create(:proposal_form, status: 'active', proposal_type: proposal_type) }
  let(:proposal_type) { create(:proposal_type) }
  let(:year) { '2021' }
  let(:params) { { proposal_type_id: proposal_type.id, year: year } }
  let(:proposal) { service_call.proposal }

  describe '.call' do
    before do
      proposal_form
    end

    it 'creates proposal' do
      expect(service_call.proposal).to be_persisted
    end

    it 'has no error' do
      expect(service_call.errors?).to be_falsey
    end

    it 'has redirect url to edit path' do
      expect(service_call.redirect_url).to eq("/proposals/#{proposal.id}/edit")
    end

    it 'has notice' do
      expect(service_call.flash_message[:notice]).to eq(I18n.t('proposals.initialize', proposal_type: proposal_type.name))
    end

    context 'when exists proposal with same type, year and organizer' do
      before do
        proposal = create(:proposal, proposal_type: proposal_type, year: year)
        lead_role = create(:role, name: 'lead_organizer')
        proposal.create_organizer_role(user.person, lead_role)
      end

      it 'does not create proposal' do
        expect { service_call }.not_to change(Proposal, :count)
      end

      it 'returns redirect url to proposal/new' do
        expect(service_call.redirect_url).to eq('/proposals/new')
      end

      it 'shows the error' do
        expect(service_call.flash_message)
          .to eq(alert: ["Year #{I18n.t('proposals.limit_per_type_per_year', proposal_type: proposal_type.name)}"])
      end
    end

    context 'when error' do
      before do
        allow_any_instance_of(described_class).to receive(:ensure_organizer_role).and_raise(StandardError)
      end

      it 'does not create proposal' do
        expect(service_call.proposal).not_to be_persisted
      end

      it 'has error' do
        expect(service_call.errors?).to be_truthy
      end

      it 'has redirect url to new proposal path' do
        expect(service_call.redirect_url).to eq("/proposals/new")
      end

      it 'has alert' do
        expect(service_call.flash_message[:alert]).to be_present
      end
    end
  end
end
