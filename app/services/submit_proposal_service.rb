class SubmitProposalService
  attr_reader :params, :proposal, :proposal_form, :errors

  def initialize(proposal, params)
    @proposal = proposal
    @proposal_form = proposal.proposal_form
    @params = params
    @errors = []
  end

  def save_answers
    ids = proposal_form.proposal_fields.pluck(:id)
    ids.each do |id|
      value = params[id.to_s]

      create_or_update(id, value)
    end
    proposal_locations
  end

  def errors?
    @errors << @proposal.errors.full_messages unless @proposal.valid?

    !@errors.flatten.empty?
  end

  def error_messages
    @errors.uniq.flatten
  end

  def final?
    params[:commit] == 'Submit Proposal'
  end

  private

  def create_or_update(id, value)
    value = nil if value.instance_of?(Array) && value&.all?(&:blank?)
    old_errors_count = @errors.flatten.count
    check_field_validations(id, value)
    return if any_new_errors?(old_errors_count)

    save_response(id, value)
  end

  def proposal_locations
    proposal.locations = Location.where(id: params[:location_ids])
  end

  def check_field_validations(id, value)
    field = ProposalField.find(id)
    return if field.location_id && @proposal.locations.exclude?(field.location)

    @errors << ProposalFieldValidationsService.new(field, proposal, value).validations
  end

  def save_response(id, value)
    answer = Answer.find_by(proposal_field_id: id, proposal: proposal)

    if answer
      answer.update(answer: value)
    else
      Answer.create(answer: value, proposal: proposal, proposal_field_id: id)
    end
  end

  def any_new_errors?(old_errors_count)
    @errors.flatten.count > old_errors_count
  end
end
