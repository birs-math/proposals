# frozen_string_literal: true

class DemographicDataPresenter
  def initialize(proposal_ids)
    @proposal_ids = proposal_ids
  end

  def fetch(*keys)
    memo.values_at(*keys.uniq).compact_blank.reduce({}, :merge)
  end

  private

  attr_reader :proposal_ids

  def memo
    return @memo if defined?(@memo)

    @memo = {}
    populate_survey_results
    populate_career_results

    @memo
  end

  def populate_survey_results
    unique_survey_results_array.each do |id_and_result|
      person_id, result = id_and_result
      answers_count = person_answer_count(person_id)

      result.each do |survey_key, answer|
        store_answers(survey_key, Array(answer), answers_count)
      end
    end
  end

  def populate_career_results
    unique_career_status_array.each do |id_and_career|
      person_id, academic_status, other_academic_status = id_and_career
      career_entries = person_answer_count(person_id)

      store_answers('academic_status', Array(academic_status), career_entries)
      store_answers('other_academic_status', Array(other_academic_status), career_entries)
    end
  end

  def store_answers(top_key, answers, answer_count)
    memo[top_key] ||= Hash.new(0)

    answers.reject { |val| empty_answer?(val) }.map { |answer| memo[top_key][answer] += answer_count }
  end

  def empty_answer?(answer)
    answer.blank? || answer.downcase.eql?('other')
  end

  # Survey answer count = confirmed invites count
  def person_answer_count(person_id)
    invited_people_ids.count { |val| val == person_id }
  end

  # Get last demographic survey result
  def unique_survey_results_array
    @unique_survey_results_array ||= DemographicData
                                     .select("DISTINCT ON (person_id) person_id, *")
                                     .order(:person_id, created_at: :desc)
                                     .where(demographic_data: { person_id: invited_people_ids })
                                     .to_a.pluck(:person_id, :result)
  end

  def unique_career_status_array
    @unique_career_status_array ||= Person
                                    .where(id: invited_people_ids)
                                    .pluck(:id, :academic_status, :other_academic_status)
  end

  # Get invited people with duplicates (those who have more than 1 confirmed invite)
  def invited_people_ids
    @invited_people_ids ||= Invite.unscoped.participant.confirmed.where(proposal_id: proposal_ids).pluck(:person_id)
  end
end
