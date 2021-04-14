require 'rails_helper'

RSpec.describe ProposalType, type: :model do
  describe 'validations' do
    it 'has valid factory' do
      expect(build(:proposal_type)).to be_valid
    end
  end

  describe 'associations' do
    it { should have_many(:proposals).dependent(:destroy) }
    it { should have_many(:proposal_forms).dependent(:destroy) }
  end
end
