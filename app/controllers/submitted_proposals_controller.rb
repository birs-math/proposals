class SubmittedProposalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_proposals, only: %i[index download_csv]

  def index; end

  def show
    @proposal = Proposal.find_by(id: params[:id])
  end

  def download_csv
    send_data @proposals.to_csv, filename: "submitted_proposals.csv"
  end

  private

  # rubocop:disable Metrics/AbcSize
  def query_params?
    params[:firstname].present? || params[:lastname].present? ||
      params[:subject_area].present? || params[:keywords].present? ||
      params[:workshop_year].present? || params[:proposal_type].present?
  end
  # rubocop:enable Metrics/AbcSize

  def set_proposals
    if query_params?
      query = ProposalFiltersQuery.new(Proposal.active_proposals)
      @proposals = query.find(params)
    else
      @proposals = Proposal.active_proposals
    end
  end
end
