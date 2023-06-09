class InvitesController < ApplicationController
  before_action :authenticate_user!, except: %i[show inviter_response thanks cancelled]
  before_action :set_proposal, only: %i[invite_reminder invite_email new_invite]
  before_action :set_invite,
                only: %i[show inviter_response invite_reminder]
  before_action :set_invite_proposal, only: %i[show]
  before_action :unsafe_set_invite, only: %i[cancel new_invite cancel_confirmed_invite]

  def show
    redirect_to root_path and return if @invite.confirmed?
    redirect_to cancelled_path and return if @invite.cancelled?

    render layout: 'devise'
  end

  def show_invite_modal
    @invite = Invite.find(params[:id])

    render partial: 'submitted_proposals/invite_modal', locals: { invite: @invite }
  end

  def update
    @proposal = Proposal.find(params[:proposal_id])
    @invite = @proposal.invites.find(params[:id])

    result = Invites::Update.new(invite: @invite, params: params[:invite]).call

    if lead_organizer?
      redirect_to edit_proposal_path(@invite.proposal_id), **result.flash_message
    else
      redirect_to edit_submitted_proposal_url(@invite.proposal_id), **result.flash_message
    end
  end

  def invite_email
    @inviters = if params[:id].eql?("0")
                  Invite.where(proposal_id: @proposal.id, invited_as: params[:invited_as])
                else
                  Invite.where(proposal_id: @proposal.id, invited_as: params[:invited_as]).where('id > ?', params[:id])
                end

    send_invite_emails

    head :ok
  end

  def inviter_response
    if invalid_response?
      return redirect_to invite_url(code: @invite&.code), alert: t('invites.inviter_response.failure')
    end

    @invite.response = response_params
    @invite.status = set_invite_status
    @invite.skip_deadline_validation = true

    if @invite.save
      if @invite.no? || @invite.maybe?
        send_email_on_response
      elsif @invite.yes?
        session[:is_invited_person] = true
        redirect_to new_person_path(code: @invite.code, response: @invite.response)
      end
    else
      redirect_to invite_url(code: @invite&.code),
                  alert: "Problem saving response: #{@invite.errors.full_messages}"
    end
  end

  def invite_reminder
    if @invite.pending?
      @organizers = @invite.proposal.list_of_organizers
      InviteMailer.with(invite: @invite, organizers: @organizers).invite_reminder.deliver_later
      check_user
    else
      redirect_to edit_proposal_path(@proposal), notice: t('invites.invite_reminder.success')
    end
  end

  def thanks
    render layout: 'devise'
  end

  def cancelled
    render layout: 'devise'
  end

  def cancel
    @invite.skip_deadline_validation = true if @invite.deadline_date < Date.current
    @invite.update(status: 'cancelled')

    if current_user.staff_member?
      redirect_to edit_submitted_proposal_url(@invite.proposal), notice: t('invites.cancel.success')
    else
      redirect_to edit_proposal_path(@invite.proposal), notice: t('invites.cancel.failure')
    end
  end

  def cancel_confirmed_invite
    @proposal_role = @invite.proposal.proposal_roles.find_by(person_id: @invite.person.id)
    @proposal_role.destroy
    @invite.skip_deadline_validation = true if @invite.deadline_date < Date.current
    @invite.update(status: 'cancelled')
    if current_user.staff_member?
      redirect_to edit_submitted_proposal_url(@invite.proposal), notice: t('invites.cancel_confirmed_invite.success')
    else
      redirect_to edit_proposal_path(@invite.proposal), notice: t('invites.cancel_confirmed_invite.success')
    end
  end

  def new_invite
    @invite.skip_deadline_validation = true if @invite.deadline_date < Date.current
    @invite.update(status: 'pending')
    if current_user.staff_member?
      redirect_to edit_submitted_proposal_url(@invite.proposal), notice: t('invites.new_invite.success')
    else
      redirect_to edit_proposal_path(@invite.proposal), notice: t('invites.new_invite.success')
    end
  end

  private

  def lead_organizer?
    @invite.proposal.lead_organizer == current_user.person
  end

  def set_invite_status
    case response_params
    when 'no'
      :cancelled
    when 'maybe'
      :pending
    when 'yes'
      :confirmed
    end
  end

  def set_invite_proposal
    @proposal = @invite&.proposal
  end

  def response_params
    params.require(:commit)&.downcase
  end

  def invalid_response?
    %w[yes no maybe].none?(response_params)
  end

  def set_invite
    @invite = Invite.safe_find(code: params[:code])

    if @invite.blank?
      @lead_organizer = Invite.find_by(code: params[:code])&.proposal&.lead_organizer

      render 'invalid_code', layout: 'devise'
    end
  end

  def set_proposal
    @proposal = Proposal.find(params[:proposal_id])
  end

  def invite_params
    params.require(:invite).permit(:firstname, :lastname, :email, :invited_as,
                                   :deadline_date)
  end

  def send_invite_emails
    @email_body = params[:body]
    @inviters.each do |invite|
      InviteMailer.with(invite: invite, body: @email_body).invite_email.deliver_later
      InviteMailer.with(invite: invite, lead_organizer: @proposal.lead_organizer,
                        body: @email_body).invite_email.deliver_later
    end
  end

  def send_email_on_response
    return unless @invite.no? || @invite.maybe?

    if @invite.no?
      InviteMailer.with(invite: @invite).invite_decline.deliver_later
    elsif @invite.maybe?
      InviteMailer.with(invite: @invite).invite_uncertain.deliver_later
    end

    redirect_to thanks_proposal_invites_path(@invite.proposal)
  end

  def check_user
    if current_user.staff_member?
      redirect_to edit_submitted_proposal_url(@proposal),
                  notice: "Invite reminder has been sent to #{@invite.person.fullname}!"
    else
      redirect_to edit_proposal_path(@proposal),
                  notice: "Invite reminder has been sent to #{@invite.person.fullname}!"
    end
  end

  def unsafe_set_invite
    @invite = Invite.find_by(code: params[:code])
  end
end
