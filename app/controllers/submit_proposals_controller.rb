class SubmitProposalsController < ApplicationController
  before_action :set_proposal, only: %i[create invitation_template]
  before_action :authorize_user, only: %w[create create_invite]
  def new
    @proposals = ProposalForm.new
  end

  def create
    @proposal.update(proposal_params)
    update_assigned_date
    update_applied_date
    update_proposal_ams_subject_code
    @submission = SubmitProposalService.new(@proposal, params)
    @submission.save_answers
    create_invite and return if params[:create_invite]

    if current_user.staff_member?
      staff_redirect
      nil
    else
      session[:is_submission] = @proposal.is_submission = @submission.final?
      if @proposal.is_submission && @submission.errors?
        flash[:alert] = []
        @submission.error_messages.each do |msg|
          flash[:alert] << msg.to_s
        end
        redirect_to edit_proposal_path(@proposal)
        return
      end
      unless @proposal.is_submission
        redirect_to edit_proposal_path(@proposal), notice: t('submit_proposals.create.alert')
        return
      end
      @attachment = generate_proposal_pdf || return
      confirm_submission
    end
  end

  def thanks; end

  def invitation_template
    invited_as = params[:invited_as]
    case invited_as
    when 'organizer'
      @email_template = EmailTemplate.find_by(email_type: "organizer_invitation_type")
    when 'participant'
      @email_template = EmailTemplate.find_by(email_type: "participant_invitation_type")
    end
    preview_placeholders
    render json: { subject: @email_template.subject, body: @template_body },
           status: :ok
  end

  private

  def create_invite
    return unless request.xhr?

    @errors = []
    @counter = 0
    params[:invites_attributes].each_value do |invite|
      @invite = @proposal.invites.new(invite_params(invite))
      invite_save
      next if @invite.errors.empty?

      invalid_email_error_message
    end
    render json: { errors: @errors, counter: @counter }, status: :ok
  end

  def invite_save
    return unless @invite.save

    log_activity(@invite)
    @counter += 1
  end

  def confirm_submission
    if @proposal.may_active?
      change_proposal_status
    elsif @proposal.may_revision?
      proposal_revision_status
    elsif @proposal.may_revision_spc?
      proposal_revision_spc_status
    else
      error_page_redirect
    end
  end

  def send_mail
    session[:is_submission] = nil
    ProposalMailer.with(proposal: @proposal, file: @attachment)
                  .proposal_submission.deliver_later
    redirect_to thanks_submit_proposals_path, notice: 'Your proposal has
        been submitted. A copy of your proposal has been emailed to
        you.'.squish
  end

  def generate_proposal_pdf
    temp_file = "propfile-#{current_user.id}-#{@proposal.id}.tex"
    version = @proposal.answers.maximum(:version).to_i
    @latex_infile = ProposalPdfService.new(@proposal.id, temp_file, 'all', current_user, version)
                                      .generate_latex_file.to_s
    render_file_string
  end

  def render_file_string
    render_to_string(layout: "application", inline: @latex_infile,
                     formats: [:pdf])
  rescue ActionView::Template::Error
    error_message = "We were unable to compile your proposal with LaTeX.
                      Please see the error messages, and generated LaTeX
                      docmument, then edit your submission to fix the
                      errors".squish
    redirect_to rendered_proposal_proposal_path(@proposal, format: :pdf),
                alert: error_message and return
  end

  def proposal_params
    params.permit(:title, :year, :subject_id, :ams_subject_ids, :location_ids,
                  :no_latex, :preamble, :bibliography, :cover_letter,
                  :same_week_as, :week_after, :assigned_date)
          .merge(no_latex: params[:no_latex] == 'on')
  end

  def proposal_id_param
    params.permit(:proposal)['proposal'].to_i
  end

  def set_proposal
    @proposal = Proposal.find(proposal_id_param)
  end

  def proposal_ams_subjects
    @code1 = params.dig(:ams_subjects, :code1)
    @code2 = params.dig(:ams_subjects, :code2)
    [@code1, @code2]
  end

  def update_proposal_ams_subject_code
    proposal_ams_subjects
    proposal_ams_subject_one
    proposal_ams_subject_two
  end

  def proposal_ams_subject_one
    ams_subject_one = ProposalAmsSubject.find_by(proposal: @proposal, code: 'code1')
    if ams_subject_one
      ams_subject_one.update(ams_subject_id: @code1)
    else
      ProposalAmsSubject.create(ams_subject_id: @code1, proposal: @proposal,
                                code: 'code1')
    end
  end

  def proposal_ams_subject_two
    ams_subject_two = ProposalAmsSubject.find_by(proposal: @proposal, code: 'code2')
    if ams_subject_two
      ams_subject_two.update(ams_subject_id: @code2)
    else
      ProposalAmsSubject.create(ams_subject_id: @code2, proposal: @proposal,
                                code: 'code2')
    end
  end

  def invite_params(invite)
    invite.permit(:firstname, :lastname, :email, :deadline_date, :invited_as)
  end

  def invalid_email_error_message
    @errors << @invite.errors.full_messages
    @errors.flatten!
    return unless @invite.errors.added? :email, "is invalid"

    @errors[@errors.index("Email is invalid")] = "Email is invalid: #{@invite.email}"
  end

  def authorize_user
    return if current_user.staff_member?
    raise CanCan::AccessDenied unless current_user&.lead_organizer?(@proposal)
  end

  def preview_placeholders
    @template_body = @email_template&.body
    if @template_body.blank?
      redirect_to new_email_template_path, alert: 'No email template found!'
      return
    end
    placing_holders
  end

  def placing_holders
    placeholders = { "Proposal_lead_organizer_name" => @proposal&.lead_organizer&.fullname,
                     "proposal_type" => @proposal.proposal_type&.name,
                     "proposal_title" => @proposal&.title }
    placeholders.each { |k, v| @template_body.gsub!(k, v) }
  end

  def staff_redirect
    if @submission.errors?
      redirect_to edit_submitted_proposal_url(@proposal), alert: "Your submission has
          errors: #{@submission.error_messages}.".squish
    else
      redirect_to submitted_proposals_url(@proposal), notice: t('submit_proposals.staff_redirect.alert')
    end
  end

  def change_proposal_status
    unless @proposal.active!
      redirect_to edit_proposal_path(@proposal), alert: "Your proposal has
                  errors: #{@proposal.errors.full_messages}.".squish and return
    end

    change_proposal_version
    send_mail
  end

  def error_page_redirect
    if @proposal.errors.any?
      redirect_to edit_proposal_path(@proposal), alert: "Your proposal has
                  errors: #{@proposal.errors.full_messages}.".squish and return
    end

    redirect_to edit_proposal_path(@proposal), alert: "The proposal status is
                #{@proposal.status&.humanize} but expecting Draft or Revision
                requested.".squish and return
  end

  def proposal_revision_spc_status
    @proposal.allow_late_submission = true if @proposal.revision_requested_spc?
    @proposal.revision_spc!
    change_proposal_version
    send_mail
  end

  def proposal_revision_status
    @proposal.allow_late_submission = true if @proposal.revision_requested?
    @proposal.revision!
    change_proposal_version
    send_mail
  end

  def change_proposal_version
    if @proposal.submitted?
      @proposal_version = ProposalVersion.new(title: @proposal.title, year: @proposal.year, proposal_id: @proposal.id,
                                              subject: @proposal.subject.id, status: @proposal.status,
                                              ams_subject_one: @proposal.ams_subjects.first.id,
                                              ams_subject_two: @proposal.ams_subjects.last.id)
      @proposal_version.save
    else
      revision_proposal_version
    end
  end

  def revision_proposal_version
    version = @proposal.proposal_versions&.maximum(:version)&.to_i
    @proposal_version = ProposalVersion.find_by(proposal_id: @proposal.id, version: version) if version.present?

    return if @proposal_version.blank?

    proposal_version = @proposal_version.dup
    update_proposal_version(proposal_version)
  end

  def update_proposal_version(proposal_version)
    proposal_version.save
    version = proposal_version.version + 1
    proposal_version.update(title: @proposal.title, year: @proposal.year,
                            proposal_id: @proposal.id, status: @proposal.status,
                            subject: @proposal.subject.id,
                            ams_subject_one: @proposal.ams_subjects.first.id,
                            ams_subject_two: @proposal.ams_subjects.last.id,
                            version: version, send_to_editflow: nil)
  end

  def update_assigned_date
    date = params[:assigned_date]
    return if date.blank?

    date = Date.parse(date.split(' - ').first)
    @proposal.update(assigned_date: date)
  end

  def update_applied_date
    date = params[:applied_date]
    return if date.blank?

    date = Date.parse(date.split(' - ').first)
    @proposal.update(applied_date: date)
  end

  def log_activity(invite)
    data = {
      logable: invite,
      user: current_user,
      data: {
        action: params[:action].humanize
      }
    }
    Log.create!(data)
  end
end
