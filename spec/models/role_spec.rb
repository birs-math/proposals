require 'rails_helper'

RSpec.describe Role, type: :model do
  it 'has valid factory' do
    expect(build(:role)).to be_valid
  end

  it 'requires a name' do
    role = build(:role, name: '')
    expect(role.valid?).to be_falsey
  end
end
