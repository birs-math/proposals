module ProposalFormsHelper
  def proposal_form_statuses
    ProposalForm.statuses.map {|k, v| [k.capitalize, k]}
  end
end