require 'rails_helper'

RSpec.describe Subject, type: :model do
  it 'has valid factory' do
    expect(build(:subject)).to be_valid
  end

  it 'requires a title' do
    subject = build(:subject, title: '')
    expect(subject.valid?).to be_falsey
  end

  it 'requires a code' do
    subject = build(:subject, code: '')
    expect(subject.valid?).to be_falsey
  end

  describe 'associations' do
    it { should have_many(:subject_area_categories).dependent(:destroy) }
    it { should have_many(:subject_categories).through(:subject_area_categories) }
    it { should have_many(:proposals) }
    it { should have_many(:ams_subjects) }
  end
end
