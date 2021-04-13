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
end
