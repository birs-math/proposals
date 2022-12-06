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
      let(:proposal) { create(:proposal, assigned_date: "2023-01-15 - 2023-01-20") }
      let!(:proposal_field) { create(:proposal_field) }
      let(:schedule_run) { create(:schedule_run) }
      let(:schedule) { create(:schedule, schedule_run_id: schedule_run.id) }
      let!(:answers) { create(:answer, proposal: proposal, proposal_field: proposal_field) }

      before do
        proposal_field.update_columns(fieldable_type: "ProposalFields::PreferredImpossibleDate")
        proposal_field.answer.update_columns(answer: "[\" 01/19/24 to 01/23/24\", \"04/11/24 to 04/15/24\", \"07/11/24 to 7/15/24\", \"08/11/24 to 08/15/24\", \"\", \"12/11/24 to 12/15/24\", \" 02/19/24 to 02/23/24\"]")
        proposal.preferred_dates
        schedule.choice
      end

      it 'returns proposal choice when preferred dates are present' do
        schedule.update(proposal: proposal.id)
        schedule_run.location.update!(end_date: "2026-10-02")
        schedule_run.location.update!(start_date: "2022-12-11")
        schedule_run.location.update!(exclude_dates: "2023-11-06")
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
