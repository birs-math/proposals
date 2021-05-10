module ProposalsHelper
  def proposal_types
    ProposalType.active_forms.map { |pt| [pt.name, pt.id] }
  end

  def locations
    Location.all.map { |loc| [loc.name, loc.id] }
  end

  def all_proposal_types
    ProposalType.all.map { |pt| [pt.name, pt.id] }
  end
end
