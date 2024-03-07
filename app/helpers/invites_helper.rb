module InvitesHelper
  def invite_statuses
    Invite.statuses.map { |k, _v| [k.capitalize, k] }
  end

  def invite_responses
    Invite.responses.map { |k, _v| [k.capitalize, k] }
  end

  def get_affiliation(invite)
    invite.person.affiliation
  end

  def max_invitations(proposal, invited_as)
    return false if location_full?(proposal)

    confirmed_invitations = confirmed_participants(proposal.id, invited_as).count
    invited_as = invited_as == 'Participant' ? invited_as.downcase : 'co_organizer'
    confirmed_invitations < proposal.proposal_type[invited_as]
  end

  def invited_role(invited)
    if invited.invited_as.include?('Organizer')
      "be a supporting organizer for"
    else
      "participate in"
    end
  end

  def confirmed_minimum_participants(proposal)
    participants = proposal.demographics_data.count
    participants >= 10
  end

  def lead_organizer(invite, user)
    invite.proposal.lead_organizer == user.person
  end

  def location_full?(proposal)
    proposal.safe_assigned_location.capacity <= proposal.invites.confirmed.count
  end
end
