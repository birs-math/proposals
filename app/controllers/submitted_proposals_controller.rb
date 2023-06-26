class SubmittedProposalsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_proposal, except: %i[index download_csv import_reviews
                                          reviews_booklet reviews_excel_booklet booklet_log]
  before_action :template_params, only: %i[approve_decline_proposals]
  before_action :check_reviews_permissions, only: %i[import_reviews
                                                     reviews_booklet
                                                     reviews_excel_booklet]

  def index
    @selected_year = params[:workshop_year] || Time.zone.today.year
    @search_params = query_params.merge(workshop_year: @selected_year)

    respond_to do |format|
      # loads initial page, but without proposals
      format.html do
        @proposal_types = ProposalType.distinct(:name).pluck(:name)
      end
      # loads proposals by type using turbo lazy loading
      format.turbo_stream do
        @type = params[:proposal_type]
        @pagy, @proposals = pagy(
          ProposalFiltersQuery.new(Proposal.order(:code, :created_at)).find(query_params), items: 20
        )
      end
    end
  end

  def show
    @proposal.review! if @proposal.may_review?
    log_activity(@proposal)
  end

  def edit
    @proposal.invites.build
  end

  def send_to_workshop
    proposals = Proposal.where(id: params[:ids].split(','))
    post_to_workshop(proposals)
  end

  def download_csv
    @proposals = Proposal.where(id: params[:ids]&.split(','))

    log_activities(@proposals)
    send_data Proposal.to_csv(@proposals), filename: "submitted_proposals.csv"
  end

  def edit_flow
    params[:ids]&.split(',')&.each do |id|
      @proposal = Proposal.find(id)
      check_proposal_status and return unless @proposal.may_progress?

      next unless post_to_editflow
    end

    respond_to do |format|
      format.js { render js: "window.location='/submitted_proposals'" }
      message = "Proposals submitted to EditFlow!"
      format.html { redirect_to submitted_proposals_path, notice: message }
    end
  end

  def revise_proposal_editflow
    @proposal = Proposal.find(params[:proposal_id])

    unless @proposal.may_requested? || @proposal.may_revision?
      return redirect_to versions_proposal_url(@proposal),
                  alert: "Proposal status should be initial_review or revision_submitted_before_review."
    end

    check_proposal_editflow_id
  end

  def staff_discussion
    @staff_discussion = StaffDiscussion.new
    discussion = params[:discussion]
    if @staff_discussion.update(discussion: discussion,
                                proposal_id: @proposal.id)
      redirect_to submitted_proposal_url(@proposal),
                  notice: "Your comment was added!"
    else
      redirect_to submitted_proposal_url(@proposal),
                  alert: @staff_discussion.errors.full_messages
    end
  end

  def send_emails
    raise CanCan::AccessDenied unless @ability.can?(:manage, Email)

    @email = Email.new(email_params.merge(proposal_id: @proposal.id))
    change_status
    unless @check_status
      @message = "Proposal status cannot be changed!"
      page_redirect_with_alert
      return
    end
    add_files
    organizers_email_addresses
    if @email.save
      @email.email_organizers(@organizers_email)
      page_redirect
    else
      @message = @email.errors.full_messages
      page_redirect_with_alert
    end
  end

  def destroy
    @proposal.destroy
    respond_to do |format|
      format.html do
        redirect_to submitted_proposals_url,
                    notice: t('submitted_proposals.destroy.success')
      end
      format.json { head :no_content }
    end
  end

  def approve_decline_proposals
    params[:proposal_ids]&.split(',')&.each do |id|
      create_birs_email(id)
      @errors = []
      render_error and return unless @check_status

      send_email_proposals
    end
    if @errors.empty?
      head :ok
    else
      render json: @errors.flatten.to_json, status: :unprocessable_entity
    end
  end

  def proposals_booklet
    proposal_ids = params[:proposal_ids]
    table = params[:table]
    counter = proposal_ids.split(',').count
    ProposalBookletJob.perform_later(proposal_ids, table, counter, current_user)
    head :accepted
  end

  def download_booklet
    file = Rails.root.join('tmp', "booklet-proposals-#{current_user.id}.pdf")

    return head(:not_found) unless file.exist?

    send_file(
      file.open,
      filename: "proposal_booklet.pdf",
      type: "application/pdf"
    )
  end

  def table_of_content
    proposals = params[:proposals]
    render json: { proposals: proposals }, status: :ok
  end

  def update_status
    status = params[:status]
    if @proposal.update(status: status.to_i)
      render json: {}, status: :ok
    else
      render json: @proposal.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update_location
    location = params[:location]
    if @proposal.update(assigned_location_id: location)
      render json: {}, status: :ok
    else
      render json: @proposal.errors.full_messages, location: :unprocessable_entity
    end
  end

  def import_reviews
    ImportJob.perform_later(params[:proposals], current_user, params[:action])
    head :accepted
  end

  def reviews_booklet
    temp_file = "propfile-#{current_user.id}-review-booklet.tex"
    ReviewJob.perform_now(params[:proposals], params[:reviewContentType],
                          params[:table], current_user, temp_file)
    head :accepted
  end

  def download_review_booklet
    pdf_file = Rails.root.join("tmp/proposal-reviews-#{current_user.id}.pdf")
    year = Date.current.year + 2
    filename = "#{year}-proposal-reviews.pdf"
    if File.exist?(pdf_file)
      file = File.open(pdf_file)
      send_file(
        file,
        filename: filename,
        type: "application/pdf"
      )
    else
      render json: "File not found: #{pdf_file}"
    end
  end

  def reviews; end

  def reviews_excel_booklet
    check_selected_proposals
    @proposals = Proposal.where(id: params[:proposals]&.split(','))
    log_activities(@proposals)
    respond_to do |format|
      format.xlsx
    end
  end

  def proposal_outcome_location
    proposals = Proposal.where(selected_proposal_ids)
    proposals.update_all(outcome_location_params.to_hash)
    head :ok
  end

  def booklet_log
    @log = LatexToPdfLog.find(params[:log_id])
  end

  def download_log_file
    log = LatexToPdfLog.find_by(id: params[:log_id])

    return head(:not_found) if log.blank?

    file = Rails.root.join('tmp', log.file_name)

    return head(:not_found) unless file.exist?

    send_file(
      file.open,
      filename: log.file_name,
      type: log.mime_type
    )
  end

  private

  def query_params
    params.permit(:workshop_year, :keywords, :proposal_type, :location, :outcome, status: [], subject_area: [])
  end

  def selected_proposal_ids
    params.require(:proposal).permit(id: [])
  end

  def outcome_location_params
    params.require(:proposal).permit(:outcome, :assigned_location_id, :assigned_size)
  end

  def email_params
    params.permit(:subject, :body, :cc_email, :bcc_email)
  end

  def change_status
    revision_template
    @check_status = @email.update_status(@proposal, 'Approval') if params[:templates].split(':').first == "Approval"
    @check_status = @email.update_status(@proposal, 'Reject') if params[:templates].split(':').first == "Reject"
    @check_status = @email.update_status(@proposal, 'Decision') if params[:templates].split.first == "Decision"
  end

  def revision_template
    case params[:templates].split(':').first
    when "Revision"
      @check_status = @email.update_status(@proposal, 'Revision')
    when "Revision SPC"
      @check_status = @email.update_status(@proposal, 'Revision SPC')
    end
  end

  def latex_temp_file
    "propfile-#{current_user.id}-#{@proposal.id}.tex"
  end

  def generate_pdf_string
    pdf_file = render_to_string layout: "application", inline: @prop_latex, formats: [:pdf]
    write_pdf_file(pdf_file)
  rescue StandardError => e
    Rails.logger.info { "\n\n#{@proposal.code} LaTeX error:\n #{e.message}\n\n" }
    flash[:alert] = "#{@proposal.code} LaTeX error: #{e.message}"
    @errors = "#{@proposal.code} LaTeX error: #{e.message}"
    ''
  end

  def write_pdf_file(pdf_file)
    File.open(@pdf_path, "w:UTF-8") do |file|
      file.write(pdf_file)
    end
  rescue StandardError => e
    Rails.logger.info { "\n\nError creating #{@proposal&.code} PDF: #{e.message}\n\n" }
    flash[:alert] = "Error creating #{@proposal&.code} PDF: #{e.message}"
    false
  end


  def post_to_workshop(proposals)
    proposals = proposals.map do |proposal|
      {
        proposal_type: proposal.proposal_type.name,
        proposal_year: proposal.year,
        proposal_id: proposal.id,
        code: proposal.code,
        workshop_name: proposal.title,
        participants: proposal.participant_invites,
        dates: proposal.assigned_date
      }
    end

    RestClient.post "#{ENV['WORKSHOPS_API_URL']}/events/proposals", {proposals: proposals}.to_json, content_type: 'application/json'
  end

  def post_to_editflow
    log_info
    return unless create_pdf_file

    begin
      edit_flow_query = EditFlowService.new(@proposal).query
    rescue RuntimeError => e
      Rails.logger.info { "\n\nErrors in #{@proposal.code}: #{e.message}\n\n" }
      flash[:alert] = "Errors in #{@proposal.code}: #{e.message}"
    end
    return if flash[:alert].present?

    response = RestClient.post ENV['EDITFLOW_API_URL'],
                               { query: edit_flow_query, fileMain: File.open(@pdf_path) },
                               { x_editflow_api_token: ENV.fetch('EDITFLOW_API_TOKEN', nil) }

    query_response_body(response)
    Rails.logger.info { "\n\n*****************************************\n\n" }
    true
  end

  def create_pdf_file
    @prop_latex = ProposalPdfService.new(@proposal.id, latex_temp_file, 'all', current_user)
                                    .generate_latex_file.to_s

    @year = @proposal&.year || (Date.current.year.to_i + 2)
    @pdf_path = Rails.root.join('tmp', "#{@proposal&.code}-#{DateTime.now.to_i}.pdf")

    generate_pdf_string
  end

  def query_response_body(response)
    if response.body.include?("errors")
      Rails.logger.info { "\n\nError sending #{@proposal.code}: #{response.body}\n\n" }
      flash[:alert] = "Error sending #{@proposal.code}: #{response.body}"
      nil
    else
      Rails.logger.info { "\n\nEditFlow response: #{response.inspect}\n\n" }
      flash[:notice] = "#{@proposal&.code} sent to EditFlow!"
      store_response_id(response)
      @proposal.progress!
    end
  end

  def store_response_id(response)
    response_body = JSON.parse(response.body)
    article = response_body["data"]["article"]

    return unless article

    @id = article["id"]
    @proposal.update(editflow_id: @id, edit_flow: DateTime.current)
    @proposal_version = @proposal.proposal_versions.find_by(version: 1)
    @proposal_version.update(editflow_id: @id, send_to_editflow: DateTime.current)
  end

  def check_proposal_editflow_id
    if @proposal.editflow_id.blank?
      redirect_to versions_proposal_url(@proposal), alert: t('submitted_proposals.check_proposal_editflow_id.failure')
    else
      revision_proposal
    end
  end

  def revision_proposal
    revise_post_to_editflow
    if @errors.present?
      redirect_to versions_proposal_url(@proposal), alert: @errors
    else
      redirect_to versions_proposal_url(@proposal), notice: t('submitted_proposals.revision_proposal.success')
    end
    nil
  end

  def revise_post_to_editflow
    log_info
    @errors = ""
    revise_query = create_file_revise_query

    return if @errors.present?

    return unless cover_letter_file

    response = RestClient.post ENV['EDITFLOW_API_URL'],
                               { query: revise_query, fileMain: File.open(@pdf_path),
                                 fileRevisionLetter: File.open(@letter_path) },
                               { x_editflow_api_token: ENV.fetch('EDITFLOW_API_TOKEN', nil) }

    mutation_response_body(response, params[:version].to_i)
  end

  def create_file_revise_query
    version = params[:version].to_i
    return unless create_revise_proposal_file(version)

    begin
      revise_query = EditFlowService.new(@proposal).revise_article
    rescue RuntimeError => e
      Rails.logger.info { "\n\nErrors in #{@proposal.code}: #{e.message}\n\n" }
      @errors = "Errors in #{@proposal.code}: #{e.message}"
    end
    revise_query
  end

  def create_revise_proposal_file(version)
    @prop_latex = ProposalPdfService.new(@proposal.id, latex_temp_file, 'all', current_user, version)
                                    .generate_latex_file.to_s

    # @year = @proposal&.year || (Date.current.year.to_i + 2)
    @pdf_path = Rails.root.join('tmp', "#{@proposal&.code}-#{DateTime.now.to_i}.pdf")
    generate_pdf_string
  end

  def log_info
    Rails.logger.info { "\n\n*****************************************\n\n" }
    Rails.logger.info { "\n\nPosting #{@proposal.code} to EditFlow...\n\n" }
    Rails.logger.info { "\n\nCreating PDF for #{@proposal&.code}...\n\n" }
  end

  def mutation_response_body(response, version)
    if response.body.include?("errors")
      Rails.logger.info { "\n\nError sending #{@proposal.code}: #{response.body}\n\n" }
      @errors = "Error sending #{@proposal.code}: #{response.body}"
      return
    else
      Rails.logger.info { "\n\nEditFlow response: #{response.inspect}\n\n" }
      @proposal.progress_spc! if store_revised_response_id(response, version)
    end
    Rails.logger.info { "\n\n*****************************************\n\n" }
  end

  def cover_letter_file
    cover_letter_pdf = cover_letter_field_pdf
    @letter_path = Rails.root.join('tmp', "#{@proposal&.code}-cover_letter.pdf")
    File.open(@letter_path, "w:UTF-8") do |file|
      file.write(cover_letter_pdf)
    end
  rescue StandardError => e
    Rails.logger.info { "\n\nError creating #{@proposal&.code} PDF: #{e.message}\n\n" }
    @errors = "Error creating #{@proposal&.code} PDF: #{e.message}"
    false
  end

  def cover_letter_field_pdf
    latex = if @proposal.cover_letter
              "\\begin{document}\n#{LatexToPdf.escape_latex(@proposal.cover_letter)}"
            else
              "\\begin{document}\n"
            end
    render_to_string layout: "application", inline: latex, formats: [:pdf]
  end

  def store_revised_response_id(response, version)
    response_body = JSON.parse(response.body)
    article = response_body["data"]["articleReviewVersion"]

    return unless article

    id = article["id"]

    proposal_version = @proposal.proposal_versions.find_by(version: version)
    proposal_version&.update(editflow_id: id, send_to_editflow: DateTime.current)
  end

  def set_proposal
    @proposal = Proposal.find(params[:id])
  end

  def template_params
    templates = params[:templates].split(": ")
    if templates.first == "Decision Email"
      type = "#{templates.first.downcase.tr!(' ', '_')}_type"
    elsif templates.first.present?
      type = "#{templates.first.downcase}_type"
    end
    template = templates.last
    @email_template = EmailTemplate.find_by(email_type: type, title: template)
    @email_template.update(subject: params[:subject], body: params[:body]) if @email_template.present?
  end

  def send_email_proposals
    add_attachments
    organizers_email = @proposal.invites.where(invited_as: 'Organizer', status: :confirmed)&.pluck(:email)
    @email.new_email_organizers(organizers_email) if @email.save
    @errors << @email.errors.full_messages unless @email.errors.empty?
  end

  def authorize_user
    authorize! params[:action], SubmittedProposalsController
  end

  def check_proposal_status
    render json: { errors: 'Please select initial review proposal(s).' }, status: :unprocessable_entity
  end

  def create_birs_email(id)
    @proposal = Proposal.find(id)
    @email = Email.new(email_params.merge(proposal_id: @proposal.id))
    change_status
  end

  def render_error
    @errors << "Proposal status cannot be changed"
    render json: @errors.flatten.to_json, status: :unprocessable_entity
  end

  def add_files
    params[:files]&.each do |file|
      @email.files.attach(file)
    end
  end

  def add_attachments
    params[:attachments]&.each do |file|
      @email.files.attach(file)
    end
  end

  def page_redirect
    if params[:action] == "show"
      redirect_to submitted_proposal_url(@proposal),
                  notice: t('submit_proposals.page_redirect.alert')
    else
      redirect_to edit_submitted_proposal_url(@proposal),
                  notice: t('submit_proposals.page_redirect.alert')
    end
  end

  def page_redirect_with_alert
    if params[:action] == "show"
      redirect_to submitted_proposal_url(@proposal),
                  alert: @message
    else
      redirect_to edit_submitted_proposal_url(@proposal),
                  alert: @message
    end
  end

  def organizers_email_addresses
    return if params[:organizers_email].blank?

    @organizers_email = JSON.parse(params[:organizers_email]).map(&:values).flatten
  end

  def check_selected_proposals
    @proposal_ids = params[:proposals]
    @no_review_proposal_ids = []
    @review_proposal_ids = []
    check_proposals_reviews
  end

  def check_proposals_reviews
    return if @proposal_ids.blank?

    pids = @proposal_ids&.is_a?(String) ? @proposal_ids&.split(',') : @proposal_ids
    pids&.each do |id|
      @proposal = Proposal.find(id)
      reviews_conditions
    end
  end

  def reviews_conditions
    if @proposal.reviews.present?
      @review_proposal_ids << @proposal.id
    elsif @proposal.editflow_id.present?
      ImportReviewsService.new(@proposal).proposal_reviews
      @review_proposal_ids << @proposal.id
    else
      @no_review_proposal_ids << @proposal.id
    end
  end

  def log_activities(proposals)
    proposals.map { |proposal| log_activity(proposal) }
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

  def check_reviews_permissions
    raise CanCan::AccessDenied unless @ability.can?(:manage, Review)
  end
end
