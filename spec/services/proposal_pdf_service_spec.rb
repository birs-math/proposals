require 'rails_helper'

RSpec.describe 'ProposalPdfService' do
  before do
    @proposal = create(:proposal)
    @temp_file = 'Test temp_file'
    @input = 'some input'
    @user = User.first
    @file_errors = []
    @text = ""
    @version = nil
    @bps = ProposalPdfService.new(@proposal.id, @temp_file, @input, @user, @version)
  end
  it 'accept a Proposal Pdf Service' do
    expect(@bps.class).to eq(ProposalPdfService)
  end
end