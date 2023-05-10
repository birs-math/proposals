# frozen_string_literal: true

module UpsertProposalValidator
  def validate
    if limit_per_type_per_year_exceeded?
      proposal.errors.add(
        :base,
        I18n.t('proposals.limit_per_type_per_year', proposal_type: proposal.proposal_type.name)
      )
    end
  end

  def limit_per_type_per_year_exceeded?
    return @exists_query_result if defined?(@exists_query_result)

    return @exists_query_result = false unless params[:year]

    @exists_query_result = current_user
                             .person
                             .lead_organizer_proposals
                             .where.not(id: proposal.id)
                             .exists?(proposal_type_id: proposal.proposal_type_id, year: params[:year])
  end
end
