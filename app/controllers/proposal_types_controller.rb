class ProposalTypesController < ApplicationController
  before_action :set_proposal_type,
                only: %i[show location_based_fields proposal_forms destroy update edit proposal_type_locations]

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
      redirect_to proposal_types_path, notice: t('proposal_types.create.success')
    else
      redirect_to new_proposal_type_path(@proposal_type), alert: @proposal_type.errors.full_messages
    end
  end

  def edit; end

  def update
    if @proposal_type.update(proposal_type_params)
      redirect_to proposal_types_path, notice: t('proposal_types.update.success')
    else
      redirect_to edit_proposal_type_path(@proposal_type), alert: @proposal_type.errors.full_messages
    end
  end

  def destroy
    @proposal_type.destroy
    redirect_to proposal_types_path
  end

  def location_based_fields
    proposal_version_field
    @proposal_fields = @proposal.proposal_form&.proposal_fields&.where(location_id: params[:ids].split(","))
    @submission = session[:is_submission]
    render partial: 'proposal_forms/proposal_fields', locals: { proposal_fields: @proposal_fields }
  end

  def proposal_type_locations
    render json: @proposal_type.locations
  end

  def proposal_forms; end

  def show; end

  def years
    @target = params[:target]
    proposal_type_year = ProposalType.find_by(id: params[:id])&.year
    @years = if proposal_type_year
               proposal_type_year.split(",").map(&:strip)
             else
               [Date.current.year + 2]
             end

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def proposal_type_params
    params.require(:proposal_type).permit(:name, :year, :co_organizer, :participant, :code, :open_date, :closed_date,
                                          :organizer_description, :participant_description, :max_no_of_preferred_dates,
                                          :min_no_of_preferred_dates, :max_no_of_impossible_dates, :capacity,
                                          :min_no_of_impossible_dates, :length, location_ids: [])
  end

  def set_proposal_type
    @proposal_type = ProposalType.find(params[:id])
  end

  def proposal_version_field
    @version = params[:proposal_version].to_i if params[:proposal_version].present?
    @proposal = Proposal.find(params[:proposal_id])
  end
end
