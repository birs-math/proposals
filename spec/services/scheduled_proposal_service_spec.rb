require 'rails_helper'

RSpec.describe 'ScheduleProposalService' do
	before do
		@proposal = create(:proposal)
    @errors = []
    @sps = ScheduledProposalService.new(@proposal)
  end
  it 'accept a proposal' do
    expect(@sps.class).to eq(ScheduledProposalService)
  end
end