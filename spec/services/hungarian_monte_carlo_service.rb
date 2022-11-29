require 'rails_helper'

RSpec.describe 'HungarianMonteCarlo' do
  before do
    schedule_run = create(:schedule_run)
    location = schedule_run.location
    errors = {}
    @hmcs = HungarianMonteCarlo.new(schedule_run: schedule_run)
  end
  it 'accept a schedule_run' do
    expect(@hmcs.class).to eq(HungarianMonteCarlo)
  end
end