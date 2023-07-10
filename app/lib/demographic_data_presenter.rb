# frozen_string_literal: true

# TODO: memo each key pluck'ed

class DemographicDataPresenter
  def initialize(proposal_ids)
    @proposal_ids = proposal_ids
  end

  def responses(*keys, source: :demographic_data)
    hash = Hash.new(0)

    pluck(*keys, source: source).each do |response|
      hash[response] += 1
    end

    hash
  end

  private

  attr_reader :proposal_ids

  def pluck(*keys, source: :demographic_data)
    case source
    when :demographic_data
      demographic_data_map.pluck(*keys)
    when :person
      person_career_status_map
    end.flatten.reject { |response| response.blank? || response.downcase.eql?('other') }
  end

  # Map survey results for each confirmed proposal a person is attending
  def demographic_data_map
    @demographic_data_map ||= invited_people_ids.map { |person_id| unique_survey_results_hash[person_id] }
  end

  # Get last demographic survey result and make a hash with person_id as key
  def unique_survey_results_hash
    @unique_survey_results_hash ||= DemographicData
                                    .select("DISTINCT ON (person_id) person_id, *")
                                    .order(:person_id, created_at: :desc)
                                    .where(demographic_data: { person_id: invited_people_ids })
                                    .to_a.pluck(:person_id, :result).to_h
  end

  # The same for career status
  def person_career_status_map
    @person_career_status_map ||= invited_people_ids.map { |person_id| unique_career_status_hash[person_id] }
  end

  # The same for career status, but transform to_h by grouping last two values into array
  def unique_career_status_hash
    @unique_career_status_hash ||= Person
                                   .where(id: invited_people_ids)
                                   .pluck(:id, :academic_status, :other_academic_status)
                                   .to_h { |array| [array[0], [array[1], array[2]]] }
  end

  # Get invited people with duplicates (those who have more than 1 confirmed invite)
  def invited_people_ids
    @invited_people_ids ||= Invite.unscoped.participant.confirmed.where(proposal_id: proposal_ids).pluck(:person_id)
  end
end
