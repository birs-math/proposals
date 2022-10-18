class ImportJob < ApplicationJob
  queue_as :default

  def perform(proposal_ids, user, action)
    @errors = ""
    proposal_ids.split(',').each do |id|
      import_proposal_reviews(id)
      log_activity(Proposal.find(id), user, action)
    end
    import_message
    call_channel
  end

  private

  def import_message
    @message_type = ""
    @message = ""
    @message_type = 'success'
    if @reviews_not_imported.present?
      error_messages
    elsif @errors.blank?
      if @no_review == "No_review_found"
        @message = "This proposal has no reviews yet."
      else
        @message = "Reviews imported successfully."
      end
    end
  end

  def error_messages
    @message = if @statuses.present?
                 "Proposal status cannot be changed, if proposal status is not in 'in_progress' or
                  'revision_submitted'"
               else
                 "Review cannot be imported for proposal with status #{@reviews_not_imported.uniq.join(', ')}.
                  may be you have to sent to EditFlow before importing".squish
               end
    @message_type = 'alert'
  end

  def import_proposal_reviews(id)
    @reviews_not_imported = []
    @statuses = []
    @proposal = Proposal.find_by(id: id)

    if @proposal.editflow_id.present?
      importing_proposal_reviews
      change_proposal_review_status if @proposal.reload.reviews.present?
    else
      @reviews_not_imported << @proposal.status
    end
  end

  def importing_proposal_reviews
    import_reviews = ImportReviewsService.new(@proposal)
    @no_review = import_reviews.proposal_reviews
    @errors << import_reviews.errors if import_reviews.errors.present?
  end

  def change_proposal_review_status
    return if @proposal.decision_pending?

    if @proposal.may_pending?
      @proposal.pending!
    else
      @reviews_not_imported << @proposal.status if @reviews_not_imported.present?
      @statuses << @proposal.status if @statuses.present?
    end
  end

  def call_channel
    if @errors || @message_type == 'alert'
      ActionCable.server.broadcast("import_channel", alert: {
                                     message: @message,
                                     errors: @errors
                                   })
    else
      ActionCable.server.broadcast("import_channel", { success:
        @message })
    end
  end

  def log_activity(proposal, user, action)
    data = {
      logable: proposal,
      user: user,
      data: {
        action: action.humanize
      }
    }
    Log.create!(data)
  end
end
