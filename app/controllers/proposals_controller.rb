class ProposalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_proposal, only: %w[show edit destroy ranking locations versions proposal_version]
  before_action :check_status, only: %w[edit]
  before_action :authorize_user, only: %w[show edit]
  before_action :set_careers, only: %w[show edit]

  def index
    @proposals = current_user&.person&.proposals
                             &.each_with_object([]) do |proposal, props|
      props << proposal if current_user&.organizer?(proposal)
    end
  end

  def ranking
    @proposal_locations = @proposal.proposal_locations
                                   .find_by(location_id: params[:location_id])
    @proposal_locations.update(position: params[:position].to_i)
    head :ok
  end

  def new
    @proposal = Proposal.new
  end

  def create
    @proposal = start_new_proposal
    @same_type_proposals = current_user.person.proposals.where(proposal_type_id: @proposal.proposal_type_id)

    @same_type_proposals.each do |proposal|
      if proposal.year == (Time.now.year + 2).to_s && !no_proposal?
        limit_of_one_per_type and return
      end
    end
    
    if @proposal.save
      @proposal.create_organizer_role(current_user.person, organizer)
      redirect_to edit_proposal_path(@proposal), notice: "Started a new
                              #{@proposal.proposal_type.name} proposal!".squish
    else
      redirect_to new_proposal_path, alert: @proposal.errors
    end
  end

  def show
    log_activity(@proposal)
  end

  def edit
    @proposal.invites.build
  end

  def locations
    render json: @proposal.locations, status: :ok
  end

  # POST /proposals/:1/latex
  def latex_input
    proposal_id = latex_params[:proposal_id]
    session[:proposal_id] = proposal_id
    ProposalPdfService.new(proposal_id, latex_temp_file, latex_params[:latex], current_user)
                      .generate_latex_file

    head :ok
  end

  # GET /proposals/:id/rendered_proposal.pdf
  def latex_output
    proposal_id = params[:id]
    @proposal = Proposal.find_by(id: proposal_id)
    generate_file
    errors = @proposal_pdf.file_errors.join(', ')

    flash[:alert] = "[#{@proposal.code}] #{@proposal.title} - attachment not added: #{errors}."
    @proposal.review! if current_user.staff_member? && @proposal.may_review?

    render_latex
  end

  # GET /proposals/:id/rendered_field.pdf
  def latex_field
    prop_id = params[:id]
    return if prop_id.blank?

    @proposal = Proposal.find_by(id: prop_id)
    @year = @proposal&.year || (Date.current.year.to_i + 2)

    @latex_infile = ProposalPdfService.new(@proposal.id, latex_temp_file, field_input, current_user)
                                      .generate_latex_file.to_s
    render_latex
  end

  def field_input
    temp_file = "#{Rails.root}/tmp/#{latex_temp_file}"
    field_input = 'all'
    if File.exist?(temp_file)
      field_input = File.read(temp_file)
      field_input = LatexToPdf.escape_latex(field_input) if @proposal.no_latex
    end
    field_input
  end

  def destroy
    @proposal.destroy
    respond_to do |format|
      format.html do
        redirect_to proposals_url, notice: t('proposals.destroy.success')
      end
      format.json { head :no_content }
    end
  end

  def upload_file
    @proposal = Proposal.find(params[:id])
    params[:files].each do |file|
      if @proposal.pdf_file_type(file)
        @proposal.files.attach(file)
        render json: "File successfully uploaded", status: :ok
      else
        render json: "File format not supported", status: :bad_request
      end
    end
  end

  def remove_file
    delete_file_message

    if request.xhr?
      if current_user.staff_member?
        render js: "window.location='#{edit_submitted_proposal_url(@proposal)}'"
      else
        render js: "window.location='#{edit_proposal_path(@proposal)}'"
      end
    else
      redirect_to edit_proposal_path(@proposal)
    end
  end

  def versions; end

  def proposal_version
    @version = params[:version].to_i
    @proposal_version = ProposalVersion.find_by(proposal_id: @proposal.id, version: @version)
  end

  private

  def proposal_params
    params.require(:proposal).permit(:proposal_type_id, :title, :year)
  end

  def organizer
    Role.find_or_create_by!(name: 'lead_organizer')
  end

  def set_proposal
    @proposal = Proposal.find_by(id: params[:id])
    @submission = session[:is_submission]
  end

  def latex_params
    params.permit(:latex, :proposal_id, :format)
  end

  def start_new_proposal
    prop = Proposal.new(proposal_params)
    prop.proposal_form = ProposalForm.active_form(prop.proposal_type_id)
    prop
  end

  def no_proposal?
    @proposal.proposal_type.not_lead_organizer?(current_user.person)
  end

  def limit_of_one_per_type
    redirect_to new_proposal_path, alert: "There is a limit of one
      #{@proposal.proposal_type.name} proposal per lead organizer in one year.".squish
  end

  def latex_temp_file
    proposal_id = latex_params[:proposal_id] || params[:id]
    "propfile-#{current_user.id}-#{proposal_id}.tex"
  end

  def render_latex
    render layout: "application", inline: @latex_infile, formats: [:pdf]
  rescue ActionView::Template::Error => e
    flash[:alert] = "There are errors in your LaTeX code. Please see the
                        output from the compiler, and the LaTeX document,
                        below".squish
    error_output = ProposalPdfService.format_errors(e)
    render layout: "latex_errors", inline: error_output.to_s, formats: [:html]
  end

  def set_careers
    @careers = Person.where(id: @proposal.participants.pluck(:person_id))
                     .pluck(:academic_status)
  end

  def check_status
    return if @proposal.editable?

    raise CanCan::AccessDenied
  end

  def delete_file_message
    @proposal = Proposal.find(params[:id])
    file = @proposal.files.where(id: params[:attachment_id])
    file.purge_later

    flash[:notice] = t('proposals.delete_file_message.success')
  end

  def authorize_user
    @current_user = current_user
    return if params[:action] == 'show' &&
              (current_user.staff_member? || current_user.organizer?(@proposal))

    return if params[:action] == 'edit' &&
              (current_user.staff_member? || current_user.lead_organizer?(@proposal))

    raise CanCan::AccessDenied
  end

  def log_activity(proposal)
    data = {
      logable: proposal,
      user: current_user,
      data: {
        action: params[:action].humanize
      }
    }
    Log.create!(data)
  end

  def generate_file
    @year = @proposal&.year || (Date.current.year.to_i + 2)
    version = @proposal.answers.maximum(:version).to_i
    @proposal_pdf = ProposalPdfService.new(@proposal.id, latex_temp_file, 'all', current_user, version)
                                      .generate_latex_file
    @latex_infile = @proposal_pdf.to_s
  end
end
