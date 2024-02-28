class InvitesController < ApplicationController
  before_action :authenticate_user!, except: %i[show inviter_response thanks cancelled]
  before_action :set_proposal, only: %i[invite_reminder new_invite]
  before_action :set_invite,
                only: %i[show inviter_response invite_reminder]
  before_action :set_invite_proposal, only: %i[show]
  before_action :unsafe_set_invite, only: %i[cancel new_invite cancel_confirmed_invite]
  before_action :authorize_user, only: %i[cancel cancel_confirmed_invite]

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

  def inviter_response
    if invalid_response?
      return redirect_to invite_url(code: @invite&.code), alert: t('invites.inviter_response.failure')
    end

    @invite.response = response_params
    @invite.status = set_invite_status
    @invite.skip_deadline_validation = true

    if @invite.save
      if @invite.no? || @invite.maybe?
        @invite.proposal.proposal_roles.delete_by(person_id: @invite.person_id)

        send_email_on_response
      elsif @invite.yes?
        session[:is_invited_person] = true

        ActiveRecord::Base.transaction do
          role = Role.find_or_create_by!(name: @invite.invited_as)
          @invite.proposal.proposal_roles.create(role: role, person: @invite.person)

          if @invite.invited_as == 'Organizer' && !@invite.person.user
            user = User.new(email: @invite.person.email,
                            password: SecureRandom.urlsafe_base64(20), confirmed_at: Time.zone.now)
            user.person = @invite.person
            user.save
          end
        end

        InviteMailer.with(invite: @invite).invite_acceptance.deliver_later

        redirect_to new_person_path(code: @invite.code, response: @invite.response)
      end
    else
      redirect_to invite_url(code: @invite&.code),
                  alert: "Problem saving response: #{@invite.errors.full_messages}"
    end
  end

  def invite_reminder
    if @invite.pending?
      InviteMailer.with(invite: @invite).invite_reminder.deliver_later
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

    redirect_to edit_submitted_proposal_url(@invite.proposal), notice: t('invites.cancel.success')
  end

  def cancel_confirmed_invite
    ActiveRecord::Base.transaction do
      @invite.proposal.proposal_roles.delete_by(person_id: @invite.person_id)
      @invite.update_attribute(:status, 'cancelled')
    end

    redirect_to edit_submitted_proposal_url(@invite.proposal), notice: t('invites.cancel_confirmed_invite.success')
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

  def authorize_user
    return if current_user.staff_member?

    redirect_back fallback_location: edit_proposal_path(@invite.proposal),
                  alert: I18n.t('errors.messages.not_authorized')
  end
end
