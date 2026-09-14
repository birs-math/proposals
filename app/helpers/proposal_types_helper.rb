module ProposalTypesHelper
  def active_or_draft_form?(id)
    proposal_type = ProposalType.find(id)
    proposal_type.proposal_forms.where(status: %i[active draft]).present?
  end

  def list_proposal_locations(proposal_type)
    return '' if proposal_type.locations.empty?

    proposal_type.locations.map(&:name).join("<br>\n").html_safe
  end
end
