# frozen_string_literal: true

class ProposalFiltersQuery
  def initialize(relation)
    @result = relation
  end

  def find(params = {})
    @result = filter_by_keyword(params[:keywords])
    @result = filter_by_workshop_year(params[:workshop_year])
    @result = filter_by_subject_area(params[:subject_area])
    @result = filter_by_proposal_type(params[:proposal_type])
    @result = filter_by_status(params[:status])
    @result = filter_by_location(params[:location])
    @result = filter_by_outcome(params[:outcome])

    @result
  end

  def filter_by_keyword(keywords)
    return @result if keywords.blank?

    @result.search_proposals(keywords)
  end

  def filter_by_workshop_year(workshop_year)
    return @result if workshop_year.blank?

    @result.search_proposal_year(workshop_year)
  end

  def filter_by_subject_area(subject_area)
    return @result if subject_area&.reject(&:blank?).blank?

    @result.where(subject_id: subject_area)
  end

  def filter_by_proposal_type(proposal_type)
    return @result if proposal_type.blank?

    @result.search_proposal_type(proposal_type)
  end

  def filter_by_status(statuses)
    return @result if statuses.blank?

    r = []
    statuses.each do |status|
      r << @result.search_proposal_status(status).sort_by { |p| p.code || '' }
    end
    @result = r.flatten
  end

  def filter_by_location(location)
    return @result if location.blank?

    @result.search_proposal_location(location)
  end

  def filter_by_outcome(outcome)
    return @result if outcome.blank?

    @result.search_proposal_outcome(outcome)
  end
end
