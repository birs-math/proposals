require 'rails_helper'

RSpec.describe SubjectCategory, type: :model do
  it 'has valid factory' do
    expect(build(:subject_category)).to be_valid
  end

  it 'requires a category name' do
    category = build(:subject_category, name: '')
    expect(category.valid?).to be_falsey
  end
end
