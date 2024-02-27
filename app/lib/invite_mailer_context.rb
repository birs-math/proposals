# frozen_string_literal: true

class InviteMailerContext
  include Callable
  include Rails.application.routes.url_helpers

  class << self
    def placeholders
      {
        person_name: '[Firstname Lastname]',
        person_firstname: '[Firstname]',
        person_lastname: '[Lastname]',
        invited_as: '[a Supporting Organizer for/a Participant in]',
        invited_role: '[Participant/Supporting Organizer]',
        proposal_type: '[Proposal type]',
        proposal_title: '[Proposal title]',
        lead_organizer: '[Lead organizer]',
        supporting_organizers: '[Supporting organizers]',
        all_organizers: "[Lead organizer and Supporting organizers]",
        deadline_date: '[Invitation deadline]',
        invite_url: '[Invite URL]'
      }.freeze
    end
  end

  def initialize(params)
    @invite = params[:invite]
    @proposal = invite.proposal
    @params = params
    @person = invite.person
  end

  def call
    {
      person_name: invitee_fullname,
      person_firstname: invitee_firstname,
      person_lastname: invitee_lastname,
      invited_as: invited_as_text(invite),
      invited_role: invite.humanize_invited_as,
      proposal_type: proposal.proposal_type.name,
      proposal_title: proposal.title,
      lead_organizer: proposal.lead_organizer&.fullname,
      supporting_organizers: supporting_organizers.join(', '),
      all_organizers: supporting_organizers.unshift(proposal.lead_organizer&.fullname).compact.join(', '),
      deadline_date: invite.deadline_date&.to_date,
      invite_url: safe_invite_url
    }
  end

  private

  attr_reader :invite, :person, :proposal, :params

  def invitee_firstname
    person&.firstname || invite.firstname
  end

  def invitee_lastname
    person&.lastname || invite.lastname
  end

  def invitee_fullname
    "#{invitee_firstname} #{invitee_lastname}"
  end

  def supporting_organizers
    @supporting_organizers ||= proposal.supporting_organizers.map(&:fullname)
  end

  def invited_as_text(invite)
    return "a Supporting Organizer for" if invite.humanize_invited_as.downcase.match?('organizer')

    "a Participant in"
  end

  def safe_invite_url
    # Omit invite code if email is copied to lead organizer
    code = params[:lead_organizer_copy].present? ? '123...' : invite.code

    invite_url(code: code)
  end
end
