module ProposalFormsHelper
  def proposal_form_statuses
    ProposalForm.statuses.map { |k, _v| [k.capitalize, k] }
  end
end
