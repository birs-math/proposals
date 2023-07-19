module ProposalsHelper
  def proposal_types
    today = DateTime.now
    proposal_type = ProposalType.active_forms.where('open_date <= ?', today)
    today = today.to_date
    proposal_type = proposal_type.where('closed_date >= ?', today)
    proposal_type.map { |pt| [pt.name, pt.id] }
  end

  def no_of_participants(id, invited_as)
    Invite.where('invited_as = ? AND proposal_id = ?', invited_as, id)
  end

  def confirmed_participants(id, invited_as)
    Invite.where('invited_as = ? AND proposal_id = ?', invited_as, id)
          .where.not(status: 'cancelled')
  end

  def proposal_type_year(proposal_type = nil)
    return [Date.current.year + 2] if proposal_type&.year.blank?

    proposal_type&.year&.split(",")&.map(&:strip)
  end

  def approved_proposals(proposal)
    [""] + Proposal.where(outcome: 'Approved', assigned_size: 'Half').pluck(:code) - [proposal.code]
  end

  def assigned_dates(location)
    return [] if location.blank? || location.start_date.blank? ||
                 location.end_date.blank?

    dates = []
    workshop_start_date = location.start_date

    while workshop_start_date <= location.end_date
      workshop_end_date = workshop_start_date + 5.days
      dates << "#{workshop_start_date} - #{workshop_end_date}"
      workshop_start_date += 7.days
    end

    [""] + (dates - location.exclude_dates)
  end

  def locations
    Location.all.map { |loc| [loc.name, loc.id] }
  end

  def all_proposal_types
    ProposalType.all.map { |pt| [pt.name, pt.id] }
  end

  def all_statuses
    Proposal.statuses.map { |k, v| [k.humanize.capitalize, v] }
  end

  def specific_proposal_statuses
    specific_status = %w[approved declined]
    statuses = Proposal.statuses.except(*specific_status)
    statuses.map { |k, v| [k.humanize.capitalize, v] }
  end

  def common_proposal_fields(proposal)
    proposal.proposal_form&.proposal_fields&.where(location_id: nil)
  end

  def proposal_roles(proposal_roles)
    proposal_roles.joins(:role).where(person_id: current_user.person&.id)
                  .pluck('roles.name').map(&:titleize).join(', ')
  end

  def lead_organizer?(proposal_roles)
    proposal_roles.joins(:role).where('person_id = ? AND roles.name = ?',
                                      current_user.person&.id,
                                      'lead_organizer').present?
  end

  def participant?(proposal_roles)
    proposal_roles.joins(:role).where('person_id = ? AND roles.name = ?',
                                      current_user.person&.id,
                                      'Participant').present?
  end

  def show_edit_button?(proposal)
    return unless params[:action] == 'edit'
    return unless proposal.editable?

    lead_organizer?(proposal.proposal_roles)
  end

  def selected_ams_subjects_code(proposal, code)
    proposal.proposal_ams_subjects.find_by(code: code)&.ams_subject_id
  end

  def max_organizers(proposal)
    numbers_to_words[proposal.max_supporting_organizers]
  end

  def invite_status(response, status)
    return "Invite has been cancelled" if status == 'cancelled'

    case response
    when "yes"
      "Invitation accepted"
    when "maybe"
      "Maybe attending"
    when nil
      "Not yet responded to invitation"
    when "no"
      "Invitation declined"
    end
  end

  def proposal_status(status)
    status&.split('_')&.map(&:capitalize)&.join(' ')
  end

  def proposal_status_class(status)
    proposals = {
      "approved" => "text-approved",
      "declined" => "text-declined",
      "draft" => "text-muted",
      "submitted" => "text-proposal-submitted",
      "initial_review" => "text-warning",
      "revision_requested_before_review" => "text-danger",
      "revision_requested_after_review" => "text-danger",
      "revision_submitted" => "text-revision-submitted",
      "revision_submitted_spc" => "text-revision-submitted",
      "in_progress" => "text-success",
      "in_progress_spc" => "text-success",
      "decision_pending" => "text-info",
      "decision_email_sent" => "text-primary"
    }
    proposals[status]
  end

  def invite_response_color(response, status)
    return 'text-danger' if status == 'cancelled'

    case response
    when "yes"
      "text-success"
    when "maybe"
      "text-warning"
    when nil
      "text-primary"
    when "no"
      "text-danger"
    end
  end

  def invite_deadline_date_color(invite)
    'text-danger' if invite.status == 'pending' &&
                     invite.deadline_date.to_date < DateTime.now.to_date
  end

  def invite_first_name(invite)
    invite.firstname || invite.person&.firstname
  end

  def invite_last_name(invite)
    invite.lastname || invite.person&.lastname
  end

  def proposal_version_title(version, proposal)
    ProposalVersion.find_by(version: version, proposal_id: proposal.id).title
  end

  def proposal_version(version, proposal)
    ProposalVersion.find_by(version: version, proposal_id: proposal.id)
    proposal_version = ProposalVersion.find_by(version: version, proposal_id: proposal.id)
    proposal_version.update(status: proposal.status) if proposal_version.status != proposal.status
    proposal_version
  end

  def proposal_outcome
    outcome = [%w[Approved Approved], %w[Rejected Rejected], %w[Declined Declined]]
    outcome.map { |disp, _value| disp }
  end
end
