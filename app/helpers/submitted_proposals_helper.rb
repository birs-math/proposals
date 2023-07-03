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

  def submitted_graph_data(param, param2, proposals)
    data = Hash.new(0)
    proposals&.each do |proposal|
      citizenships = proposal.demographics_data.pluck(:result)
                             .pluck(param, param2).flatten.reject do |s|
        s.blank? || s.eql?("Other")
      end

      citizenships.each { |c| data[c] += 1 }
    end
    data
  end

  def submitted_nationality_data(proposals)
    submitted_graph_data("citizenships", "citizenships_other", proposals)
  end

  def submitted_ethnicity_data(proposals)
    submitted_graph_data("ethnicity", "ethnicity_other", proposals)
  end

  def submitted_gender_labels(proposals)
    data = submitted_graph_data("gender", "gender_other", proposals)
    data.keys
  end

  def submitted_gender_values(proposals)
    data = submitted_graph_data("gender", "gender_other", proposals)
    data.values
  end

  def submitted_career_data(param, param2, proposals)
    data = Hash.new(0)
    proposals&.each do |proposal|
      career_stage = proposal_career_stage(param, param2, proposal)

      career_stage.each { |s| data[s] += 1 }
    end
    data
  end

  def proposal_career_stage(param, param2, proposal)
    person = Person.where.not(id: proposal.lead_organizer&.id)
    person.where(id: proposal.person_ids).pluck(param, param2)
          .flatten.reject do |s|
      s.blank? || s.eql?("Other")
    end
  end

  def submitted_career_labels(proposals)
    data = submitted_career_data("academic_status", "other_academic_status",
                                 proposals)
    data.keys
  end

  def submitted_career_values(proposals)
    data = submitted_career_data("academic_status", "other_academic_status",
                                 proposals)
    data.values
  end

  def submitted_stem_graph_data(proposals)
    data = Hash.new(0)
    proposals&.each do |proposal|
      citizenships = proposal.demographics_data.pluck(:result).pluck("stem")
                             .flatten.reject do |s|
        s.blank? || s.eql?("Other")
      end

      citizenships.each { |c| data[c] += 1 }
    end
    data
  end

  def submitted_stem_labels(proposals)
    data = submitted_stem_graph_data(proposals)
    data.keys
  end

  def submitted_stem_values(proposals)
    data = submitted_stem_graph_data(proposals)
    data.values
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
