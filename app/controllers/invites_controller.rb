class InvitesController < ApplicationController
  before_action :authenticate_user!, except: %i[show inviter_response thanks expired]
  before_action :set_proposal, only: %i[invite_reminder invite_email]
  before_action :set_invite, only: %i[show inviter_response cancel invite_reminder invite_email]
  before_action :set_invite_proposal, only: %i[show]

  def show
    redirect_to root_path, alert: "Invite code is invalid" and return if @invite.nil?
    redirect_to root_path and return if @invite.confirmed?
    redirect_to expired_path and return if @invite.cancelled?

    render layout: 'devise'
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
      redirect_to invite_url(code: @invite&.code), alert: 'Invalid answer'
      return
    end

    @invite.response = response_params
    @invite.status = 'confirmed',
    @invite.skip_deadline_validation = true

    if @invite.save
      create_role
      send_email_on_response
    else
      redirect_to invite_url(code: @invite&.code),
                  alert: "Problem saving response: #{@invite.errors.full_messages}"
    end
  end

  def invite_reminder
    if @invite.pending?
      @organizers = @invite.proposal.list_of_organizers
      InviteMailer.with(invite: @invite, organizers: @organizers).invite_reminder.deliver_later
      redirect_to edit_proposal_path(@proposal), notice: "Invite reminder has been sent to #{@invite.person.fullname}!"
    else
      redirect_to edit_proposal_path(@proposal), notice: "You have already responded to the invite."
    end
  end

  def thanks
    render layout: 'devise'
  end

  def expired
    render layout: 'devise'
  end

  def cancel
    @invite.skip_deadline_validation = true if @invite.deadline_date < Date.current
    @invite.update(status: 'cancelled')
    redirect_to edit_proposal_path(@invite.proposal), notice: 'Invite has been cancelled!'
  end

  private

  def set_invite_proposal
    @proposal = Proposal.find_by(id: @invite&.proposal)
  end

  def response_params
    params.require(:commit)&.downcase
  end

  def invalid_response?
    %w[yes no maybe].none?(response_params)
  end

  def create_role
    return if @invite.no?

    proposal_role
    create_user if @invite.invited_as == 'Organizer' && !@invite.person.user
  end

  def create_user
    user = User.new(email: @invite.person.email,
                    password: SecureRandom.urlsafe_base64(20), confirmed_at: Time.zone.now)
    user.person = @invite.person
    user.save
  end

  def set_invite
    @invite = Invite.find_by(code: params[:code])
  end

  def set_proposal
    @proposal = Proposal.find(params[:proposal_id])
  end

  def invite_params
    params.require(:invite).permit(:firstname, :lastname, :email, :invited_as,
                                   :deadline_date)
  end

  def send_invite_emails
    @inviters.each do |invite|
      InviteMailer.with(invite: invite, lead_organizer: @proposal.lead_organizer).invite_email.deliver_later
    end
  end

  def proposal_role
    role = Role.find_or_create_by!(name: @invite.invited_as)
    @invite.proposal.proposal_roles.create(role: role, person: @invite.person)
  end

  def send_email_on_response
    @organizers = @invite.proposal.list_of_organizers.remove(@invite.person&.fullname)

    if @invite.no?
      InviteMailer.with(invite: @invite).invite_decline.deliver_later
      redirect_to thanks_proposal_invites_path(@invite.proposal)
    else
      InviteMailer.with(invite: @invite, organizers: @organizers)
                  .invite_acceptance.deliver_later
      redirect_to new_person_path(code: @invite.code)
    end
  end
end
