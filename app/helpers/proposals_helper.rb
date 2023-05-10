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

  def proposal_ams_subjects_code(proposal, code)
    proposal.proposal_ams_subjects.find_by(code: code)&.ams_subject_id
  end

  def max_organizers(proposal)
    numbers_to_words[proposal.max_supporting_organizers]
  end

  def existing_organizers(invite)
    organizers = invite.proposal.list_of_organizers
                       .remove(invite.person&.fullname)
    organizers.prepend(" and ") if organizers.present?
    organizers.strip.delete_suffix(",")
  end

  def invite_status(response, status)
    return "Invite has been cancelled" if status == 'cancelled'

    case response
    when "yes"
      "Invitation accepted"
    when "maybe"
      "Invitation pending"
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

  def invite_response_color(status)
    case status
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

  def graph_data(param, param2, proposal)
    citizenships = proposal.demographics_data.pluck(:result)
                           .pluck(param, param2).flatten.reject do |s|
      s.blank? || s.eql?("Other")
    end
    data = Hash.new(0)

    citizenships.each do |c|
      data[c] += 1
    end
    data
  end

  def nationality_data(proposal)
    graph_data("citizenships", "citizenships_other", proposal)
  end

  def ethnicity_data(proposal)
    graph_data("ethnicity", "ethnicity_other", proposal)
  end

  def gender_labels(proposal)
    data = graph_data("gender", "gender_other", proposal)
    data = gender_graph(data)
    data.keys
  end

  def gender_values(proposal)
    data = graph_data("gender", "gender_other", proposal)
    data = gender_graph(data)
    data.values
  end

  def career_data(param, param2, proposal)
    person = Person.where.not(id: proposal.lead_organizer.id)
    career_stage = person.where(id: proposal.invites.where(invited_as: 'Participant')
                         .pluck(:person_id)).pluck(param, param2)
                         .flatten.reject do |s|
                           s.blank? || s.eql?("Other")
                         end
    data = Hash.new(0)

    career_hash(data, career_stage)
  end

  def career_hash(data, career_stage)
    career_stage.each do |s|
      data[s] += 1
    end
    data
  end

  def career_labels(proposal)
    data = career_data("academic_status", "other_academic_status", proposal)
    data.keys
  end

  def career_values(proposal)
    data = career_data("academic_status", "other_academic_status", proposal)
    data.values
  end

  def stem_graph_data(proposal)
    citizenships = proposal.demographics_data.pluck(:result).pluck("stem")
                           .flatten.reject do |s|
      s.blank? || s.eql?("Other")
    end
    data = Hash.new(0)

    citizenships.each do |c|
      data[c] += 1
    end
    data
  end

  def stem_labels(proposal)
    data = stem_graph_data(proposal)
    data.keys
  end

  def stem_values(proposal)
    data = stem_graph_data(proposal)
    data.values
  end

  def gender_graph(data)
    if data.key?('Prefer not to answer') &&
       data.key?('Gender fluid and/or non-binary person')
      data = gender_add(data, 0)
    else
      single_data_delete(data)
    end
    data
  end

  def gender_add(data, values)
    gender_option = ['Gender fluid and/or non-binary person', 'Prefer not to answer']
    data.map do |k, v|
      [
        (values += v.to_i if gender_option.include?(k))
      ]
    end
    gender_delete(data, values)
  end

  def gender_delete(data, values)
    data.delete('Prefer not to answer')
    data.delete('Gender fluid and/or non-binary person')
    data.merge({ "Other" => values })
  end

  def single_data_delete(data)
    data.map do |k, v|
      [
        case k
        when 'Prefer not to answer'
          single_gender_delete(data, 'Prefer not to answer', v)
        when 'Gender fluid and/or non-binary person'
          single_gender_delete(data, 'Gender fluid and/or non-binary person', v)
        end
      ]
    end
  end

  def single_gender_delete(data, option, val)
    data.delete(option)
    data.merge({ "Other" => val })
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
