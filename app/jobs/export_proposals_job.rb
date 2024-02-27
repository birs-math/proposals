class ExportProposalsJob < ApplicationJob
  queue_as :default

  def workshops_api
    url = ENV['WORKSHOPS_API_URL']
    Rails.logger.info("WORKSHOPS_API_URL not set!") if url.blank?
    url
  end

  def publish_proposal(proposal, url)
    request_body = WorkshopsApiProposal.new(proposal).event
    response = RestClient.post url, request_body.to_json, content_type: :json, accept: :json
    Rails.logger.info("Posted proposal #{proposal.code} to Workshops. Response: #{response}")
  rescue => e
    Rails.logger.info("Error posting proposal #{proposal.code} to Workshops: #{e}. Response: #{response}")
  end

  def perform(proposal_codes)
    url = workshops_api
    return if url.blank?

    proposal_codes.each do |code|
      proposal = Proposal.find(code)
      next if proposal.blank?

      publish_proposal(proposal, url)
    end
  end
end
