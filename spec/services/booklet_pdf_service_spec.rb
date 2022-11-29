require 'rails_helper'

RSpec.describe 'BookletPdfService' do
	before do
		@proposal = create(:proposal)
    @temp_file = 'Test temp_file'
    @input = 'some input'
    @user = User.first
    @bps = BookletPdfService.new(@proposal.id, @temp_file, @input, @user)
  end
  it 'accept a proposal' do
    expect(@bps.class).to eq(BookletPdfService)
  end
end