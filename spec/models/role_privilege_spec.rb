require 'rails_helper'

RSpec.describe RolePrivilege, type: :model do
  it 'has valid factory' do
    expect(build(:role)).to be_valid
  end
end
