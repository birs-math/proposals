class ProposalTypesController < ApplicationController
  before_action :set_proposal_type, only: %i[show location_based_fields]

  def index
    @proposal_types = ProposalType.all
  end

  def show
    form = @proposal_type.proposal_forms.last
    @proposal_fields = form&.proposal_fields
    render partial: 'proposal_forms/form', locals: { proposal_fields: @proposal_fields }
  end

  def location_based_fields
    form = @proposal_type.proposal_forms.last
    @proposal_fields = form&.proposal_fields.where(location_id: params[:ids].split(","))
    render partial: 'proposal_forms/form', locals: { proposal_fields: @proposal_fields }
  end

  private

  def set_proposal_type
  	@proposal_type = ProposalType.find(params[:id])
  end
end
