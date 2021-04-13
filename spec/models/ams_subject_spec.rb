require 'rails_helper'

RSpec.describe AmsSubject, type: :model do
  it 'has valid factory' do
    expect(build(:ams_subject)).to be_valid
  end

  it 'requires a title' do
    subject = build(:ams_subject, title: '')
    expect(subject.valid?).to be_falsey
  end

  it 'requires a code' do
    subject = build(:ams_subject, code: '')
    expect(subject.valid?).to be_falsey
  end
end
