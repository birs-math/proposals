class ProposalBookletChannel < ApplicationCable::Channel
  def subscribed
    stream_from "proposal_booklet_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
