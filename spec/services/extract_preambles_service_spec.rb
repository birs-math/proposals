require 'rails_helper'

RSpec.describe 'ExtractPreamblesService' do
	before do
		@proposals = create_list(:proposal,3)
    @eps = ExtractPreamblesService.new(@proposals)
  end
  it 'accept a Extract Preambles Service' do
    expect(@eps.class).to eq(ExtractPreamblesService)
  end
end