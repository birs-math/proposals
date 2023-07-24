module SubmittedProposalsHelper
  def proposal_type_groups
    @proposal_type_groups ||=
      ProposalType
      .distinct(:name)
      .where.not(name: [ProposalType::FIVE_DAY_WORKSHOP, ProposalType::SUMMER_SCHOOL])
      .pluck(:name)
      .unshift(ProposalType::FIVE_DAY_WORKSHOP_AND_SUMMER_SCHOOL)
  end

  def all_proposal_types
    @all_proposal_types ||= ProposalType.pluck(:name, :id)
  end

  def demographic_data
    @demographic_data ||= DemographicDataPresenter.new(@proposal_ids)
  end

  def submitted_nationality_data
    demographic_data.fetch('citizenships', 'citizenships_other')
  end

  def submitted_ethnicity_data
    demographic_data.fetch('ethnicity', 'ethnicity_other')
  end

  def submitted_gender_labels
    demographic_data.fetch('gender', 'gender_other').keys
  end

  def submitted_gender_values
    demographic_data.fetch('gender', 'gender_other').values
  end

  def submitted_career_labels
    demographic_data.fetch('academic_status', 'other_academic_status').keys
  end

  def submitted_career_values
    demographic_data.fetch('academic_status', 'other_academic_status').values
  end

  def submitted_stem_labels
    demographic_data.fetch('stem').keys
  end

  def submitted_stem_values
    demographic_data.fetch('stem').values
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

  def edi_reviews_count(proposal_id)
    @edi_reviews_count ||= Review.unscoped.edi.where(proposal: @proposals).group(:proposal_id).count
    @edi_reviews_count[proposal_id] || 0
  end

  def scientific_reviews_count(proposal_id)
    @scientific_reviews_count ||= Review.unscoped.scientific.where(proposal: @proposals).group(:proposal_id).count
    @scientific_reviews_count[proposal_id] || 0
  end
end
