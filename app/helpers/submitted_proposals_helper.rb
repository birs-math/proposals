module SubmittedProposalsHelper

  def proposal_years
    @proposal_years ||= Proposal.distinct.pluck(:year).compact_blank.sort.append(ProposalFiltersQuery::EMPTY_YEAR)
  end

  def proposal_type_groups
    @proposal_type_groups ||=
      ProposalType
      .distinct(:name)
      .where.not(name: [ProposalType::FIVE_DAY_WORKSHOP, ProposalType::SUMMER_SCHOOL])
      .pluck(:name)
      .unshift(ProposalType::FIVE_DAY_WORKSHOP_AND_SUMMER_SCHOOL)
  end

  def all_proposal_types
    ProposalType.all.map { |pt| [pt.name, pt.id] }
  end

  def demographic_data
    @demographic_data ||= DemographicDataPresenter.new(@proposal_ids)
  end

  def submitted_nationality_data
    demographic_data.responses('citizenships', 'citizenships_other')
  end

  def submitted_ethnicity_data
    demographic_data.responses('ethnicity', 'ethnicity_other')
  end

  def gender_data
    @gender_data ||= demographic_data.responses('gender', 'gender_other')
  end

  def submitted_gender_labels
    gender_data.keys
  end

  def submitted_gender_values
    gender_data.values
  end

  def career_data
    @career_data ||= demographic_data.responses('academic_status', 'other_academic_status', source: :person)
  end

  def submitted_career_labels
    career_data.keys
  end

  def submitted_career_values
    career_data.values
  end

  def stem_data
    @stem_data ||= demographic_data.responses('stem')
  end

  def submitted_stem_labels
    stem_data.keys
  end

  def submitted_stem_values
    stem_data.values
  end

  def organizers_email(proposal)
    proposal.invites.where(invited_as: 'Organizer').map(&:person).map(&:email)
  end

  def review_dates(review)
    date = review.review_date
    date&.split(', ')
  end

  def proposal_logs(proposal)
    logs = proposal.answers.map(&:logs).reject(&:empty?) + proposal.invites.map(&:logs).reject(&:empty?) + proposal.logs
    logs.flatten.sort_by { |log| -log.created_at.to_i }
  end

  def invites_logs(log)
    "#{log.user&.fullname} invited #{log.data['firstname']&.last}
    #{log.data['lastname']&.last} #{log.data['email']&.last} as #{log.data['invited_as']&.last} at #{log&.created_at}"
  end

  def seleted_assigned_date(proposal)
    proposal.assigned_date ? "#{proposal.assigned_date} - #{proposal.assigned_date + 5.days}" : ''
  end
end
