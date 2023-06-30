require 'rails_helper'

RSpec.describe ProposalBookletChannel, type: :channel do
  let(:current_user) { create(:user) }

  it "subscribes to a stream" do
    stub_connection(current_user: current_user)

    subscribe

    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_for(current_user)
  end
end
