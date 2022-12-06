require 'rails_helper'

RSpec.describe 'ImportReviewsService' do
	before do
		@proposal = create(:proposal)
    @errors = []
    @irs = ImportReviewsService.new(@proposal)
  end
  it 'accept a proposal' do
    expect(@irs.class).to eq(ImportReviewsService)
  end
end