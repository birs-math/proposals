require 'rails_helper'

RSpec.describe 'SubmitProposalService' do
	before do
		@proposal = create(:proposal)
    @proposal_form = @proposal.proposal_form
    @params = 'some_params'
    @errors = []
    @sps = SubmitProposalService.new(@proposal, @params)
  end
  it 'accept a proposal' do
    expect(@sps.class).to eq(SubmitProposalService)
  end
end