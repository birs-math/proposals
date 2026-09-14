module ProposalTypesHelper
  def active_or_draft_form?(id)
    proposal_type = ProposalType.find(id)
    proposal_type.proposal_forms.where(status: %i[active draft]).present?
  end

  def clone_confirm_message(proposal_type_id)
    proposal_type = ProposalType.find_by(id: proposal_type_id)
    active_form = proposal_type&.proposal_forms&.find_by(status: :active)
    stale_count = active_form ? Proposal.draft.where(proposal_form_id: active_form.id).count : 0
    t('proposal_forms.clone_confirm', count: stale_count)
  end

  def list_proposal_locations(proposal_type)
    return '' if proposal_type.locations.empty?

    proposal_type.locations.map(&:name).join("<br>\n").html_safe
  end
end
