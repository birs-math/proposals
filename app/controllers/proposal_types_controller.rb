class ProposalTypesController < ApplicationController
  before_action :set_proposal_type, only: %i[show location_based_fields proposal_forms destroy update edit proposal_type_locations]

  def index
    @proposal_types = ProposalType.all
    redirect_to proposals_path and return unless current_user&.staff_member?
  end

  def new
    @proposal_type = ProposalType.new
  end

  def create
    @proposal_type = ProposalType.new(proposal_type_params)
    if @proposal_type.save
      redirect_to proposal_types_path
    else
      render :new
    end
  end

  def edit; end

  def update
    if @proposal_type.update(proposal_type_params)
      redirect_to proposal_types_path
    else
      render :edit
    end
  end

  def destroy
    @proposal_type.destroy
    redirect_to proposal_types_path
  end

  def location_based_fields
    @proposal = Proposal.find(params[:proposal_id])
    @proposal_fields = @proposal.proposal_form&.proposal_fields&.where(location_id: params[:ids].split(","))
    @publish = true if params[:publish] == 'true'
    render partial: 'proposal_forms/proposal_fields', locals: { proposal_fields: @proposal_fields }
  end

  def proposal_type_locations
    render json: @proposal_type.locations
  end

  def proposal_forms; end

  private

  def proposal_type_params
   params.require(:proposal_type).permit(:name, :co_organizer, :participant, location_ids: [])
  end

  def set_proposal_type
    @proposal_type = ProposalType.find(params[:id])
  end
end
