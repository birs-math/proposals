require 'rails_helper'

RSpec.describe 'ProposalFieldValidationsService' do

  context "validations with proposal" do
    let(:proposal) { create(:proposal, assigned_date: "2023-01-15 - 2023-01-20") }
    let!(:proposal_field) { create(:proposal_field) }
    let(:schedule_run) { create(:schedule_run) }
    let(:schedule) { create(:schedule, schedule_run_id: schedule_run.id) }
    let!(:answers) { create(:answer, proposal: proposal, proposal_field: proposal_field) }
  	before do
      @errors = []
      @pfvs = ProposalFieldValidationsService.new(proposal_field,proposal)
      @pfvs.check_validations(proposal_field.validations)
    end
    it 'accept a proposal' do
      expect(@pfvs.class).to eq(ProposalFieldValidationsService)
    end
    it "#validations when proposal present" do
      answer = answers.proposal_field.answer
      ans = Answer.find_by(proposal_field_id: proposal_field.id, proposal_id:proposal.id).answer
      expect(@pfvs.validations).to eq(@errors)
    end
  end

  context "without proposal" do
    before do
      @errors = []
      @pfvs = ProposalFieldValidationsService.new(nil,nil)
    end
    it "#validation return when proposal not present" do
      expect(@pfvs.validations).to eq(nil)
    end
  end
end