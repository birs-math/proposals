# frozen_string_literal: true

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
      demographic_data.pluck(*keys)
    when :person
      person_career_status
    end.flatten.reject { |response| response.blank? || response.downcase.eql?('other') }
  end

  def demographic_data
    @demographic_data ||= DemographicData.where(person_id: invited_people_ids).pluck(:result)
  end

  def person_career_status
    @person_career_status ||=
      Person.where(id: invited_people_ids).pluck(:academic_status, :other_academic_status)
  end

  def invited_people_ids
    @invited_people_ids ||=
      Invite.unscoped.participant.confirmed.where(proposal_id: proposal_ids).distinct.pluck(:person_id)
  end
end
