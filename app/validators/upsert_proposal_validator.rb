# frozen_string_literal: true

# I did not really want Proposal to run heavy validations each time a record is saved,
# that is why this is not using `validate_with klass` in proposal.rb.
module UpsertProposalValidator
  # works around ActiveRecord clearing custom errors on save
  def validate_and_save(halt_on_error: false)
    validate
    rollback_invalid_attributes

    raise ActiveRecord::RecordInvalid if validation_errors? && halt_on_error

    proposal.save
  ensure
    populate_errors
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

    if @exists_query_result
      validation_errors[:year] = I18n.t('proposals.limit_per_type_per_year', proposal_type: proposal.proposal_type.name)
    end

    @exists_query_result
  end

  def validation_errors
    @validation_errors ||= {}
  end

  def rollback_invalid_attributes
    validation_errors.each do |attr, _|
      proposal.public_send("#{attr}=".to_sym, proposal.public_send("#{attr}_was".to_sym))
    rescue
      next
    end
  end

  def populate_errors
    validation_errors.each do |attr, error|
      proposal.errors.add(attr, error)
    end
  end

  def validation_errors?
    validation_errors.present?
  end
end
