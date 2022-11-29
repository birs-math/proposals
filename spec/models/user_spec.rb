
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

  describe 'associations' do
    it { should have_many(:user_roles).dependent(:destroy) }
    it { should have_many(:roles).through(:user_roles) }
    it { should have_one(:person) }
    it { should have_many(:feedback) }
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

  describe '#fullname' do
    let(:user) { create(:user) }
    let(:fullname) { "#{user.person.firstname} #{user.person.lastname}" }

    it 'returns fullname of user' do
      expect(user.fullname).to eq(fullname)
    end
  end
end
