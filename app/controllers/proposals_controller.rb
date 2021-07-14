class ProposalsController < ApplicationController
  before_action :set_proposal, only: %w[show edit destroy ranking locations]
  before_action :set_careers, only: %w[show edit]
  before_action :authenticate_user!
  
  def index
    @proposals = current_user&.person&.proposals
  end

  def ranking
    @proposal_locations = @proposal.proposal_locations.find_by(location_id: params[:location_id])
    @proposal_locations.update(position: params[:position].to_i)
    head :ok
  end

  def new
    @proposal = Proposal.new
  end

  def create
    @proposal = start_new_proposal
    limit_of_one_per_type and return unless no_proposal?

    if @proposal.save
      @proposal.create_organizer_role(current_user.person, organizer)
      redirect_to edit_proposal_path(@proposal), notice: "Started a new
                              #{@proposal.proposal_type.name} proposal!".squish
    else
      redirect_to new_proposal_path, alert: @proposal.errors
    end
  end

  def show; end

  def edit
    @invite = @proposal.invites.new
  end

  def locations
    render json: @proposal.locations, status: :ok
  end

  # POST /proposals/:1/latex
  def latex_input
    proposal_id = latex_params[:proposal_id]
    session[:proposal_id] = proposal_id

    input = latex_params[:latex]
    ProposalPdfService.new(proposal_id, latex_temp_file, input).pdf

    head :ok
  end

  # GET /proposals/:id/rendered_proposal.pdf
  def latex_output
    proposal_id = params[:id]
    ProposalPdfService.new(proposal_id, latex_temp_file, 'all').pdf

    @proposal = Proposal.find_by_id(proposal_id)
    @year = @proposal&.year || Date.current.year.to_i + 2

    fh = File.open("#{Rails.root}/tmp/#{latex_temp_file}")
    @latex_input = fh.read

    render_latex
  end

  # GET /proposals/:id/rendered_field.pdf
  def latex_field
    prop_id = params[:id]
    return if prop_id.blank?

    @proposal = Proposal.find_by_id(prop_id)
    @year = @proposal&.year || Date.current.year.to_i + 2

    fh = File.open("#{Rails.root}/tmp/#{latex_temp_file}")
    @latex_input = fh.read

    render_latex
  end

  def destroy
    @proposal.destroy
    respond_to do |format|
      format.html { redirect_to proposals_url, notice: "Proposal was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def proposal_params
    params.require(:proposal).permit(:proposal_type_id, :title, :year)
  end

  def organizer
    Role.find_or_create_by!(name: 'lead_organizer')
  end

  def set_proposal
    @proposal = Proposal.find_by_id(params[:id])
    @submission = session[:is_submission]
  end

  def latex_params
    params.permit(:latex, :proposal_id, :format)
  end

  def start_new_proposal
    prop = Proposal.new(proposal_params)
    prop.status = :draft
    prop.proposal_form = ProposalForm.active_form(prop.proposal_type_id)
    prop
  end

  def no_proposal?
    @proposal.proposal_type.not_lead_organizer?(current_user.person)
  end

  def limit_of_one_per_type
    redirect_to new_proposal_path, alert: "There is a limit of one
      #{@proposal.proposal_type.name} proposal per lead organizer.".squish
  end

  def latex_temp_file
    proposal_id = latex_params[:proposal_id] || params[:id]
    "propfile-#{current_user.id}-#{proposal_id}.tex"
  end

  def render_latex
    begin
      render layout: "application", inline: "#{@latex_input}", formats: [:pdf]
    rescue ActionView::Template::Error => error
      flash[:alert] = "There are errors in your LaTeX code. Please see the
                        output from the compiler, and the LaTeX document,
                        below".squish
      error_output = ProposalPdfService.format_errors(error)
      render layout: "latex_errors", inline: "#{error_output}", formats: [:html]
    end
  end

  def set_careers
    @careers = Person.where(id: @proposal.participants.pluck(:person_id)).pluck(:academic_status)
  end
end
