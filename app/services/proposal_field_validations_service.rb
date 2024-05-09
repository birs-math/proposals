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
        @errors << error_message(val) if @answer.blank?
      when 'less than (integer matcher)'
        @errors << error_message(val) unless @answer.to_i < val.value.to_i
      when 'less than (float matcher)'
        @errors << error_message(val) unless @answer.to_f < val.value.to_f
      when 'greater than (integer matcher)'
        @errors << error_message(val) unless @answer.to_i > val.value.to_i
      when 'greater than (float matcher)'
        @errors << error_message(val) unless @answer.to_f > val.value.to_f
      when 'equal (string matcher)'
        @errors << error_message(val) unless @answer == val.value
      when 'equal (integer matcher)'
        @errors << error_message(val) unless @answer.to_i == val.value.to_i
      when 'equal (float matcher)'
        @errors << error_message(val) unless @answer.to_f == val.value.to_f
      when 'words limit'
        texcount = `echo "#{@answer}" | texcount -total -`
        word_count = texcount.match(/Words in text: (\d+)/)[1]
        @errors << error_message(val) unless word_count.to_i <= val.value.to_i
      when '5-day workshop preferred/Impossible dates'
        preferred_impossible_dates_validation(val)
      end
    end
  end

  def preferred_impossible_dates_validation(val)
    if @answer.nil?
      @errors << date_error_message(val,
        "You have to choose atleast #{proposal.proposal_type.min_no_of_preferred_dates} preferred dates")
      @errors << date_error_message(val,
        "You have to choose atleast #{proposal.proposal_type.min_no_of_impossible_dates} impossible dates")
      return
    end
    preferred = JSON.parse(@answer)&.first(5)
    impossible = JSON.parse(@answer)&.last(2)
    preferred_dates = preferred.reject { |date| date == '' }
    impossible_dates = impossible.reject { |date| date == '' }
    uniq_dates = JSON.parse(@answer).reject { |date| date == '' }
    @errors << date_error_message(val,
      "You can't select the same date twice") unless uniq_dates.uniq.count == uniq_dates.count
    if preferred_dates.count > proposal.proposal_type.max_no_of_preferred_dates
      @errors << date_error_message(val,
        "You can choose maximum #{proposal.proposal_type.max_no_of_preferred_dates} preferred dates")
    end
    if preferred_dates.count < proposal.proposal_type.min_no_of_preferred_dates
      @errors << date_error_message(val,
        "You have to choose atleast #{proposal.proposal_type.min_no_of_preferred_dates} preferred dates")
    end
    if impossible_dates.count > proposal.proposal_type.max_no_of_impossible_dates
      @errors << date_error_message(val,
        "You can choose maximum #{proposal.proposal_type.max_no_of_impossible_dates} impossible dates")
    end
    if impossible_dates.count < proposal.proposal_type.min_no_of_impossible_dates
      @errors << date_error_message(val,
        "You have to choose atleast #{proposal.proposal_type.min_no_of_impossible_dates} impossible dates")
    end
  end
  def attached_file
    !Answer.find_by(proposal_field_id: field.id, proposal_id: proposal.id)&.file&.attached?
  end

  def error_message(validation)
    validation.error_message.prepend("Step 2 ##{validation.proposal_field.position} ")
  end

  def date_error_message(validation, message)
    message.prepend("Step 2 ##{validation.proposal_field.position} ")
  end
end
