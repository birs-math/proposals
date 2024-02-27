# frozen_string_literal: true

module Proposals
  class Initialize
    include Callable
    include UpsertProposalValidator

    Result = Struct.new(:flash_message, :proposal, :url, keyword_init: true) do
      include Rails.application.routes.url_helpers

      def initialize(proposal:, flash_message: {}, url: nil)
        super
      end

      def redirect_url
        return url if url

        if flash_message[:notice]
          edit_proposal_path(proposal)
        else
          new_proposal_path
        end
      end

      def errors?
        flash_message[:alert].present?
      end
    end

    def initialize(current_user:, proposal_params:)
      @current_user = current_user
      @proposal_params = proposal_params
    end

    def call
      create_proposal

      Result.new(
        flash_message: { notice: I18n.t('proposals.initialize', proposal_type: proposal.proposal_type.name) },
        proposal: proposal
      )
    rescue
      Result.new(flash_message: { alert: error_messages }, proposal: proposal)
    end

    private

    attr_reader :current_user, :proposal_params
    alias :params :proposal_params

    def create_proposal
      ActiveRecord::Base.transaction do
        attach_form
        validate_and_save(halt_on_error: true)
        ensure_organizer_role
      end
    end

    def attach_form
      proposal.proposal_form = ProposalForm.active_form(proposal.proposal_type_id)
    end

    def ensure_organizer_role
      proposal.create_organizer_role(current_user.person, organizer_role)
    end

    def proposal
      @proposal ||= Proposal.new(proposal_params)
    end

    def organizer_role
      @organizer_role ||= Role.organizer
    end

    def error_messages
      if proposal.errors.present?
        proposal.errors.full_messages
      else
        I18n.t('errors.messages.something_went_wrong')
      end
    end
  end
end
