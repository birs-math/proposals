require 'rails_helper'

RSpec.describe Location, type: :model do
  it 'has valid factory' do
    expect(build(:location)).to be_valid
  end

  it 'requires code' do
    location = build(:location, code: '')
    expect(location.valid?).to be_falsey
  end

  it 'requires name' do
    location = build(:location, name: '')
    expect(location.valid?).to be_falsey
  end

  it 'requires country' do
    location = build(:location, country: '')
    expect(location.valid?).to be_falsey
  end

  it 'requires city' do
    location = build(:location, city: '')
    expect(location.valid?).to be_falsey
  end

  describe 'associations' do
    it { should have_many(:proposal_types).through(:proposal_type_locations) }
    it { should have_many(:proposal_types).through(:proposal_type_locations) }
    it { should have_many(:proposals).through(:proposal_locations) }
    it { should have_many(:proposal_fields) }
  end
end
