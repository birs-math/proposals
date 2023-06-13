require 'rails_helper'

RSpec.describe SubjectsHelper, type: :helper do
  describe "#subjects_area" do
    let(:subject_category) { create(:subject_category) }
    let(:subject) { create(:subject, subject_category_id: subject_category.id) }

    it "returns subjects area [title, id]" do
      subject
      expect(subjects_area).to eq([[subject.title, subject.id]])
    end
  end

  describe "#ams_subjects_code" do
    let(:subject_category) { create(:subject_category) }
    let(:subject) { create(:subject, subject_category_id: subject_category.id) }
    let(:ams_subject) { create(:ams_subject, subject_category_ids: subject_category.id, subject_id: subject.id) }

    it 'returns ams subjects [title, id]' do
      ams_subject
      expect(ams_subjects_select).to eq([[ams_subject.title, ams_subject.id]])
    end
  end

  describe "#ams_subject_title" do
    let(:subject_category) { create(:subject_category) }
    let(:subject) { create(:subject, subject_category_id: subject_category.id) }
    let(:ams_subject) { create(:ams_subject, subject_category_ids: subject_category.id, subject_id: subject.id) }

    it 'returns ams subjects [title, id]' do
      ams_subject.update(title: 'test title')
      expect(ams_subject_title(ams_subject)).to be_a String
      expect(ams_subject_title(ams_subject)).to eq ' title'
    end
  end
end
