class ProposalFieldValidationsService
  attr_reader :proposal, :field

  def initialize(field, proposal)
    @proposal = proposal
    @field = field
    @errors = []
  end

  def validations
    return unless proposal

    @answer = Answer.find_by(proposal_field_id: field.id, proposal_id: proposal.id)&.answer
    check_validations(field.validations)
    @errors
  end

  def check_validations(validations)
    validations.each do |val|
      case val.validation_type
      when 'mandatory'
        @errors << val.error_message if @answer.blank?
      when 'less than (integer matcher)'
        @errors << val.error_message unless @answer.to_i < val.value.to_i
      when 'less than (float matcher)'
        @errors << val.error_message unless @answer.to_f < val.value.to_f
      when 'greater than (integer matcher)'
        @errors << val.error_message unless @answer.to_i > val.value.to_i
      when 'greater than (float matcher)'
        @errors << val.error_message unless @answer.to_f > val.value.to_f
      when 'equal (string matcher)'
        @errors << val.error_message unless @answer == val.value
      when 'equal (integer matcher)'
        @errors << val.error_message unless @answer.to_i == val.value.to_i
      when 'equal (float matcher)'
        @errors << val.error_message unless @answer.to_f == val.value.to_f
      when 'words limit'
        texcount = `echo "#{@answer}" | texcount -total -`
        word_count = texcount.match(/Words in text: (\d+)/)[1]
        @errors << val.error_message unless word_count.to_i <= val.value.to_i
      when '5-day workshop preferred/Impossible dates'
        preferred_impossible_dates_validation
      end
    end
  end

  def preferred_impossible_dates_validation
    if @answer.nil?
      @errors << "You have to choose atleast #{proposal.proposal_type.min_no_of_preferred_dates}
      preferred dates"
      @errors << "You have to choose atleast #{proposal.proposal_type.min_no_of_impossible_dates}
      impossible dates"
      return
    end
    preferred = JSON.parse(@answer)&.first(5)
    impossible = JSON.parse(@answer)&.last(2)
    preferred_dates = preferred.reject { |date| date == '' }
    impossible_dates = impossible.reject { |date| date == '' }
    uniq_dates = JSON.parse(@answer).reject { |date| date == '' }
    @errors << "You can't select the same date twice" unless uniq_dates.uniq.count == uniq_dates.count
    if preferred_dates.count > proposal.proposal_type.max_no_of_preferred_dates
      @errors << "You can choose maximum #{proposal.proposal_type.max_no_of_preferred_dates}
      preferred dates"
    end
    if preferred_dates.count < proposal.proposal_type.min_no_of_preferred_dates
      @errors << "You have to choose atleast #{proposal.proposal_type.min_no_of_preferred_dates}
      preferred dates"
    end
    if impossible_dates.count > proposal.proposal_type.max_no_of_impossible_dates
      @errors << "You can choose maximum #{proposal.proposal_type.max_no_of_impossible_dates}
      impossible dates"
    end
    if impossible_dates.count < proposal.proposal_type.min_no_of_impossible_dates
      @errors << "You have to choose atleast #{proposal.proposal_type.min_no_of_impossible_dates}
      impossible dates"
    end
  end

  def attached_file
    !Answer.find_by(proposal_field_id: field.id, proposal_id: proposal.id)&.file&.attached?
  end
end
