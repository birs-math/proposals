require 'rails_helper'

RSpec.describe 'ReviewsBook' do
	before do
		@proposal = create(:proposal)
    @text = "some text"
    @temp_file = "some file"
    @errors = []
    @content_type = "some content type"
    @table = "table"
    @rb = ReviewsBook.new(@proposal.id, @temp_file, @content_type, @table)
  end
  it 'accept a review book' do
    expect(@rb.class).to eq(ReviewsBook)
  end
end