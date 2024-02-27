# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invites::Update do
  subject(:result) { described_class.new(invite: invite, params: params).call }

  let(:invite) { create(:invite) }
  let(:params) do
    ActiveSupport::HashWithIndifferentAccess.new(
      { firstname: 'John', lastname: 'Doe', email: 'john.doe@example.com', affiliation: 'BIRS' }
    )
  end

  def expect_to_update_attributes
    expect(result.invite.firstname).to eq('John')
    expect(result.invite.lastname).to eq('Doe')
    expect(result.invite.email).to eq('john.doe@example.com')
    expect(result.invite.person.affiliation).to eq('BIRS')
  end

  describe '#call' do
    it { expect(result.success?).to be_truthy }

    it('performs update') { expect_to_update_attributes }

    context 'when bad params' do
      let(:params) do
        ActiveSupport::HashWithIndifferentAccess.new(
          { firstname: 'John', lastname: 'Doe', email: '' }
        )
      end

      it { expect(result.success?).to be_falsey }

      it 'has error message' do
        expect(result.flash_message[:alert]).to include('Email can\'t be blank')
        expect(result.flash_message[:alert]).to include('Email is invalid')
      end
    end

    context 'when past invite deadline date' do
      before do
        invite.assign_attributes(deadline_date: Date.yesterday)
      end

      it { expect(result.success?).to be_truthy }

      it('still updates') { expect_to_update_attributes }
    end
  end
end
