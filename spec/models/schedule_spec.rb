require 'rails_helper'

RSpec.describe Schedule, type: :model do
  describe 'validations' do
    it 'has valid factory' do
      expect(build(:schedule)).to be_valid
    end

    it 'requires a case_num' do
      p = build(:schedule, case_num: '')
      expect(p.valid?).to be_falsey
    end

    it 'requires a week' do
      p = build(:schedule, week: '')
      expect(p.valid?).to be_falsey
    end

    it "requires an hmc_score" do
      p = build(:schedule, hmc_score: '')
      expect(p.valid?).to be_falsey
    end

    it "has a schedule_run_id" do
      p = build(:schedule, schedule_run_id: '')
      expect(p.valid?).to be_falsey
    end
  end

  describe 'associations' do
    it { should belong_to(:schedule_run) }
  end

  describe '#choice' do
    context "when proposal is empty" do
      let(:proposal) { create(:proposal, assigned_date: "2023-01-15 - 2023-01-20", code: "23wt4ed") }
      let(:schedule_run) { create(:schedule_run) }
      let(:schedule) { create(:schedule, schedule_run_id: schedule_run.id, proposal: "23wetdf45") }

      it 'returns empty string when proposal not found' do
        expect(schedule.choice).to eq("")
      end
    end

    context "when proposal is present" do
      let(:proposal) { create(:proposal, assigned_date: "2023-01-15 - 2023-01-20") }
      let(:schedule_run) { create(:schedule_run) }
      let(:schedule) { create(:schedule, schedule_run_id: schedule_run.id) }
      it 'returns empty string when proposal preferred_dates are empty' do
        schedule.update(proposal: proposal.id)
        expect(schedule.choice).to eq("")
      end
    end

    context "when proposal is present" do
      let(:locations) { create_list(:location, 4) }
      let!(:proposal_type) { create(:proposal_type, locations: locations) }
      let!(:proposal) { create(:proposal, proposal_type: proposal_type, assigned_date: "2023-01-15 - 2023-01-20") }
      let!(:proposal_field) { create(:proposal_field, :preferred_impossible_dates_field) }
      let!(:schedule_run) { create(:schedule_run) }
      let!(:schedule) { create(:schedule, schedule_run_id: schedule_run.id) }
      let!(:answers) do
        create(:answer, proposal: proposal, proposal_field: proposal_field, answer: "[\"01/15/23 to 01/20/2023\"]")
      end

      it 'returns empty string when proposal preferred_dates are empty' do
        schedule.update(proposal: proposal.id)
        expect(schedule.choice).to eq(0)
      end
    end
  end

  describe '#top_score' do
    let(:proposal) { create(:proposal, assigned_date: "2023-01-15 - 2023-01-20", code: "23wt4ed") }
    let(:schedule_run) { create(:schedule_run) }
    let(:schedule) { create(:schedule, schedule_run_id: schedule_run.id, proposal: proposal) }
    it 'expecting response accordingly' do
      expect(schedule.top_score).to be_present
    end
  end

  describe '#dates' do
    let(:proposal) { create(:proposal, assigned_date: "2023-01-15 - 2023-01-20", code: "23wt4ed") }
    let(:schedule_run) { create(:schedule_run) }
    let(:schedule) { create(:schedule, schedule_run_id: schedule_run.id, proposal: proposal) }
    it 'if schedule run location week is not zero ' do
      expect(schedule.dates).to be_present
    end

    it 'if schedule run location week is zero ' do
      schedule_run.location.update(start_date: '')
      expect(schedule.dates).not_to be_present
    end
  end
end
