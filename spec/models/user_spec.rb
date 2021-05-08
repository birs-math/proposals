require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has valid factory' do
    expect(build(:user)).to be_valid
  end

  it 'requires a email' do
    user = build(:user, email: '')
    expect(user.valid?).to be_falsey
  end

  it 'requires a password' do
    user = build(:user, password: '')
    expect(user.valid?).to be_falsey
  end

  describe 'when created' do
    let(:staff_user) { create(:user, email: 'staff.user@birs.ca') }
    let(:user) { create(:user) }

    it 'assigns staff role to user having domain birs.ca' do
      expect(staff_user.roles.first.name).to eq('Staff')
    end

    it 'not create staff role for user' do
      expect(user.roles).to eq([])
    end
  end

  describe '#staff_memeber?' do
    let(:staff_user) { create(:user, email: 'staff.user@birs.ca') }

    it 'returns true if user has role staff' do
      expect(staff_user.staff_member?).to be_truthy
    end
  end
end
