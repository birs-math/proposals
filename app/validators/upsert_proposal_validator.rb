# frozen_string_literal: true

# I did not really want Proposal to run heavy validations each time a record is saved,
# that is why this is not using `validate_with klass` in proposal.rb.
module UpsertProposalValidator
  # works around ActiveRecord clearing custom errors on save
  def validate_and_save(halt_on_error: false)
    validate
    rollback_invalid_attributes

    unless validation_errors? && halt_on_error
      proposal.save
    end

    populate_errors

    raise ActiveRecord::RecordInvalid if validation_errors? && halt_on_error
  end

  private

  def validate
    check_limit_per_type_per_year
  end

  def check_limit_per_type_per_year
    return @exists_query_result if defined?(@exists_query_result)

    return @exists_query_result = false unless params[:year]

    @exists_query_result = current_user
                             .person
                             .lead_organizer_proposals
                             .where.not(id: proposal.id)
                             .exists?(proposal_type_id: proposal.proposal_type_id, year: params[:year])

    validation_errors << :year if @exists_query_result
  end

  def validation_errors
    @validation_errors ||= []
  end

  def rollback_invalid_attributes
    validation_errors.each do |attr|
      proposal.public_send("#{attr}=".to_sym, proposal.public_send("#{attr}_was".to_sym))
    rescue
      next
    end
  end

  def populate_errors
    validation_errors.each do |attr|
      next unless errors_map[attr]

      proposal.errors.add(attr, errors_map[attr])
    end
  end

  def errors_map
    @errors_map ||= {
      year:  I18n.t('proposals.limit_per_type_per_year', proposal_type: proposal.proposal_type.name)
    }
  end

  def validation_errors?
    validation_errors.present?
  end
end