module ProposalFieldsHelper
  def proposal_type_locations(proposal_type)
    proposal_type.locations.map { |loc| ["#{loc.name} (#{loc.city}, #{loc.country})", loc.id] }
  end

  def proposal_field_options(field)
    options = []
    field.options.each do |option|
      options.push([option.text, option.value])
    end
    options
  end

  def options(field)
    opt = []
    field.options.each do |option|
      opt.push(option.text)
    end
    opt
  end

  def options_for_field(field)
    return unless field.fieldable_type.in?(%w[ProposalFields::SingleChoice ProposalFields::MultiChoice
                                              ProposalFields::Radio])

    options(field)
  end

  def answer(field, proposal)
    return unless proposal

    Answer.find_by(proposal_field_id: field.id, proposal_id: proposal.id)&.answer
  end

  def answer_with_version(field, proposal, version)
    return unless proposal

    Answer.find_by(proposal_field_id: field.id, proposal_id: proposal.id, version: version)&.answer
  end

  def multichoice_answer(field, proposal)
    return unless proposal

    answer = Answer.find_by(proposal_field_id: field.id, proposal_id: proposal.id)&.answer
    if answer
      JSON.parse(answer)
    else
      answer
    end
  end

  def multichoice_answer_with_version(field, proposal, version)
    return unless proposal

    answer = Answer.find_by(proposal_field_id: field.id, proposal_id: proposal.id, version: version)&.answer
    if answer
      JSON.parse(answer)
    else
      answer
    end
  end

  def location_in_answers(proposal)
    proposal.locations.pluck(:id)
  end

  def validations(field, proposal)
    return [] if field.location_id && proposal.locations.exclude?(field.location)

    ProposalFieldValidationsService.new(field, proposal).validations
  end

  def proposal_field_partial(field)
    "proposal_fields/#{field.fieldable_type.split('::').last.underscore}"
  end

  def preferred_impossible_dates(field, attr)
    field.fieldable[attr].split(",").map { |date| [date, date] }
  end

  def dates_answer(field, proposal, attr)
    ans = answer(field, proposal)
    if ans
      JSON.parse(ans)[attr.to_i]
    else
      ans
    end
  end

  def dates_answer_with_version(field, proposal, attr, version)
    ans = answer_with_version(field, proposal, version)
    if ans
      JSON.parse(ans)[attr.to_i]
    else
      ans
    end
  end

  def action
    params[:action] == 'show' || params[:action] == 'proposal_version' ||
      (params[:action] == 'location_based_fields' && request.referer.exclude?('edit'))
  end

  def disable_proposal_meeting_type
    params[:action] == 'show' || params[:action] == 'edit' 
  end

  def mandatory_field?(field)
    return print_validation if field.validations.where(validation_type: 'mandatory').present?

    ''
  end

  def print_validation
    '<span class="required"></span>'.html_safe
  end

  def location_name(field)
    return unless field.location_id

    loc = "#{field.location&.name} (#{field.location&.city}, #{field.location&.country})"
    "#{loc} - Based question"
  end

  def active_tab(proposal, tab, param_tab)
    tab_errors(proposal, param_tab).eql?(tab) ? 'active' : ''
  end

  def tab_errors(proposal, param_tab)
    return 'two' if param_tab == "tab-2"
    return 'one' unless session[:is_submission] || params[:action] == 'edit'
    return 'one' if tab_one(proposal)
    return 'two' if tab_two(proposal)
    return 'three' if tab_three(proposal)

    'one'
  end

  def tab_one(proposal)
    proposal.title.blank? || proposal.subject.blank? ||
      !proposal.ams_subjects.count.eql?(2) ||
      proposal.invites.count do |i|
        i.status == 'confirmed'
      end.zero?
  end

  def tab_two(proposal)
    errors = []
    proposal.proposal_form.proposal_fields.where(location_id: nil).each do |field|
      errors << ProposalFieldValidationsService.new(field, proposal).validations

      return true if errors.flatten.count == 1
    end
    false
  end

  def tab_three(proposal)
    return true if proposal.locations.empty?

    errors = []
    proposal.proposal_form.proposal_fields.where(location_id: proposal.location_ids).each do |field|
      errors << ProposalFieldValidationsService.new(field, proposal).validations
      return true if errors.flatten.count == 1
    end
    false
  end

  def answer_obj(field, proposal)
    return unless proposal

    Answer.find_by(proposal_field_id: field.id, proposal_id: proposal.id)
  end

  def can_edit(proposal_form)
    current_user&.staff_member? && (proposal_form&.active? || proposal_form&.draft?) && params[:action] == 'edit'
  end
end
