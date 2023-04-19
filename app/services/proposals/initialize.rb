# frozen_string_literal: true

module Proposals
  class Initialize
    include Callable

    Result = Struct.new(:flash_message, :proposal, :url, keyword_init: true) do
      include Rails.application.routes.url_helpers

      def initialize(flash_message:, proposal:, url: nil)
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
        flash_message: { notice: I18n.t('proposals.initialize', proposal_type: new_proposal.proposal_type.name) },
        proposal: new_proposal
      )
    rescue
      Result.new(flash_message: { alert: error_message }, proposal: new_proposal)
    end

    private

    attr_reader :current_user, :proposal_params

    def create_proposal
      ActiveRecord::Base.transaction do
        attach_form
        new_proposal.save
        ensure_organizer_role
      end
    end

    def attach_form
      new_proposal.proposal_form = ProposalForm.active_form(new_proposal.proposal_type_id)
    end

    def ensure_organizer_role
      new_proposal.create_organizer_role(current_user.person, organizer_role)
    end

    def new_proposal
      @new_proposal ||= Proposal.new(proposal_params)
    end

    def organizer_role
      @organizer_role ||= Role.organizer
    end

    def error_message
      if new_proposal.errors.present?
        new_proposal.errors.full_messages
      else
        I18n.t('errors.messages.something_went_wrong')
      end
    end
  end
end
