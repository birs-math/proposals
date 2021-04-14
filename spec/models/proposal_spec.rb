require 'rails_helper'

RSpec.describe Proposal, type: :model do
  describe 'validations' do
    it 'has valid factory' do
      expect(build(:proposal)).to be_valid
    end
  end

  describe 'associations' do
    it { should belong_to(:location) }
    it { should belong_to(:proposal_type) }
  end
end
