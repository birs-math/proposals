require 'rails_helper'

RSpec.describe SchedulesHelper, type: :helper do
  describe "#schedule_proposal" do
    let(:proposal) { create(:proposal, code: "23wt32") }
    let(:schedule_run) { create(:schedule_run) }
    let(:schedule1) { create(:schedule, proposal: "23wt32", schedule_run_id: schedule_run.id) }
    let(:schedule2) { create(:schedule, proposal: "214t3e", schedule_run_id: schedule_run.id) }
    let(:schedule) { create(:schedule, proposal: "", schedule_run_id: schedule_run.id) }
    let(:proposal1) { create(:proposal, code: "") }

    it "returns proposal [code,title] if it has code" do
      proposal
      schedule1
      expect(schedule_proposal(schedule1.proposal)).to eq("[#{link_to proposal.code, submitted_proposal_path(proposal),
                                                                      target: :blank}] #{proposal.title}")
    end

    it "returns no proposal [code,title] if it has no code" do
      proposal1
      schedule
      expect(schedule_proposal(schedule.proposal)).to eq("")
    end

    it "returns no proposal [code,title] if it has no code" do
      proposal
      schedule2.update(proposal: "#{proposal.code}")
      expect(schedule_proposal(schedule2.proposal)).to be_a String
    end

    it "returns exclude date if proposal code is w66" do
      proposal_code = 'w66'
      expect(schedule_proposal(proposal_code)).to eq("(excluded date)")
    end
  end

  describe "#proposals_count" do
    context " when code is 'and' " do
      let(:proposal) { create(:proposal, code: '23 and 5009w') }
      let(:schedules) { create_list(:schedule, 5, proposal: '23 and 5009w') }
      it " returns count of proposal" do
        expect(proposals_count(schedules)).to eq(10)
      end
    end
    context " when code is blank " do
      let(:proposal) { create(:proposal, code: '') }
      let(:schedule) { create(:schedule, proposal: '') }
      it " returns count of proposal" do
        expect(proposals_count([schedule])).to eq(0)
      end
    end
    context " when code is 'w66' " do
      let(:proposal) { create(:proposal, code: '23w66') }
      let(:schedule) { create(:schedule, proposal: '23w66') }
      it " returns count of proposal" do
        expect(proposals_count([schedule])).to eq(0)
      end
    end
  end

  describe "#link_to_results" do
    context "when no schedules exitst" do
      let(:schedule_run) { create(:schedule_run) }
      it "returns no results" do
        expect(link_to_results(schedule_run)).to eq('(no results yet)')
      end
    end
    context "when schedules exitst" do
      let(:schedule_run) { create(:schedule_run) }
      let(:schedules) { create_list(:schedule, 5, schedule_run_id: schedule_run.id) }
      it "returns link to view results" do
        schedule_run
        schedules
        link = link_to('View results', optimized_schedule_schedules_url(run_id: schedule_run.id))
        expect(link_to_results(schedule_run)).to eq(link)
      end
    end
  end

  describe "#link_to_schedule_result" do
    context "when no schedules exitst" do
      let(:schedule_run) { create(:schedule_run) }
      it "retruns id of schedule run" do
        schedule_run
        expect(link_to_schedule_result(schedule_run, schedule_run.id)).to eq(schedule_run.id)
      end
    end
    context "when schedules exitst" do
      let(:schedule_run) { create(:schedule_run) }
      let(:schedules) { create_list(:schedule, 5, schedule_run_id: schedule_run.id) }
      it "retruns link to schedule run id" do
        schedule_run
        schedules
        link = link_to(schedule_run.id, optimized_schedule_schedules_url(run_id: schedule_run.id))
        expect(link_to_schedule_result(schedule_run, schedule_run.id)).to eq(link)
      end
    end
  end

  describe "#schedule_run_time" do
    context "when no schedules exitst" do
      let(:schedule_run) { create(:schedule_run, start_time: '') }
      it "retruns empty string" do
        schedule_run
        expect(schedule_run_time(schedule_run)).to eq('')
      end
    end
    context "when schedules exitst" do
      let(:schedule_run) { create(:schedule_run, end_time: '') }
      it "retruns link to 'abort the run' " do
        schedule_run
        link = link_to('Abort the run', abort_run_schedules_path(run_id: schedule_run.id), method: :post)
        expect(schedule_run_time(schedule_run)).to eq(link)
      end
    end
    context "when schedules exitst" do
      let(:run) { create(:schedule_run) }
      it "retruns time " do
        run
        expect(schedule_run_time(run)).to eq("00:00:00")
      end
    end
  end

  describe "#proposal_manual_assignments" do
    context 'if proposal exist' do
      let(:proposal) { create(:proposal, code: '3W3', assigned_date: 'Tue, 14 Dec 2021') }
      let(:schedule_run) { create(:schedule_run) }
      let(:schedules) { create_list(:schedule, 5, schedule_run_id: schedule_run.id, proposal: proposal.code) }
      it "returns the count" do
        proposal
        expect(proposal_manual_assignments(schedules.pluck(:proposal))).to eq(5)
      end
    end
  end

  describe "#choice_assignment" do
    context "when choices  do not exist" do
      it "returns empty string" do
        expect(choice_assignment([], 2)).to eq('')
      end
    end
    context "when choices exist" do
      it "returns count" do
        expect(choice_assignment([1, 2, 3, 4, 5], 3)).to eq(1)
      end
    end
  end

  describe '#delete_shedule_run' do
    let(:proposal) { create(:proposal, code: '3W3', assigned_date: 'Tue, 14 Dec 2021') }
    let(:schedule_run) { create(:schedule_run) }

    context 'when shedules are present' do
      let!(:schedules) { create_list(:schedule, 5, schedule_run_id: schedule_run.id, proposal: proposal.code) }

      it 'when shedules are present' do
        expect(delete_shedule_run(schedule_run)).to be_present
      end
    end
  end

  describe '#program_years' do
    it 'returns list of years in array' do
      expect(program_years).to be_present
      expect(program_years).to be_a Array
    end
  end
end
