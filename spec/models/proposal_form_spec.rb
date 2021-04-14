require 'rails_helper'

RSpec.describe ProposalForm, type: :model do
  describe 'validations' do
    it 'has valid factory' do
      expect(build(:proposal_form)).to be_valid
    end
  end

  describe 'associations' do
    it { should belong_to(:proposal_type) }
    it { should have_many(:proposal_fields) }
  end
end
