# frozen_string_literal: true

class InviteMailerContext
  include Callable
  include Rails.application.routes.url_helpers

  CONTEXT_VARS = {
    person_name: 'Firstname + Lastname',
    person_firstname: '',
    person_lastname: '',
    invited_as: '"a Supporting Organizer for" or "a Participant in"',
    invited_role: '"Participant" or "Supporting organizer"',
    proposal_type: '',
    proposal_title: '',
    lead_organizer: '',
    supporting_organizers: 'Organizers except lead organizer',
    all_organizers: "Lead organizer + supporting organizers",
    deadline_date: '',
    invite_url: ''
  }.freeze

  def initialize(params)
    @invite = params[:invite]
    @organizers = params[:organizers].dup
    @proposal = invite.proposal
  end

  def call
    {
      person_name: invite.person&.fullname,
      person_firstname: invite.person&.firstname,
      person_lastname: invite.person&.lastname,
      invited_as: invited_as_text(invite),
      invited_role: invite.humanize_invited_as,
      proposal_type: proposal.proposal_type.name,
      proposal_title: proposal.title,
      lead_organizer: proposal.lead_organizer&.fullname,
      supporting_organizers: organizers.join(', '),
      all_organizers: organizers.unshift(proposal.lead_organizer&.fullname).compact.join(', '),
      deadline_date: invite.deadline_date&.to_date,
      invite_url: invite_url(code: invite.code)
    }
  end

  private

  attr_reader :invite, :proposal
  attr_accessor :organizers

  def invited_as_text(invite)
    return "a Supporting Organizer for" if invite.humanize_invited_as.downcase.match?('organizer')

    "a Participant in"
  end
end
