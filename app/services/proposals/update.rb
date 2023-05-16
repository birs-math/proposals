# frozen_string_literal: true

module Proposals
  class Update
    include Callable
    include UpsertProposalValidator

    MODEL_ATTRS = %i[title year subject_id ams_subject_ids location_ids
                     no_latex preamble bibliography cover_letter applied_date
                     same_week_as week_after assigned_date assigned_size].freeze

    Result = Struct.new(:submission, :proposal, :error_messages, keyword_init: true) do
      def initialize(submission:, proposal:, error_messages: [])
        super
      end

      def flash_message
        return @flash_message if defined?(@flash_message)

        if errors? || error_messages.present?
          messages = { alert: [] }

          proposal.errors.full_messages.each do |error|
            messages[:alert] << error
          end

          submission.error_messages.each do |error|
            messages[:alert] << error.to_s
          end

          error_messages.each do |error|
            messages[:alert] << error
          end

          @flash_message = messages
        else
          @flash_message = {}
        end
      end

      def errors?
        proposal.errors.present? || submission.errors?
      end
    end

    def initialize(current_user:, proposal:, params:)
      @current_user = current_user
      @proposal = proposal
      @params = params
    end

    def call
      update_proposal

      Result.new(submission: submission, proposal: proposal)
    rescue ActiveRecord::RecordInvalid => e
      Result.new(submission: submission, proposal: proposal, error_messages: [e.message])
    end

    private

    attr_reader :proposal, :params, :current_user

    def update_proposal
      ActiveRecord::Base.transaction do
        proposal.assign_attributes(model_params)
        validate_and_save
        update_ams_subject_codes
        submit_proposal
      end
    end

    def model_params
      @model_params ||= params.dup.permit(*MODEL_ATTRS).tap do |proposal_params|
        applied_date = proposal_params[:applied_date]

        if applied_date
          proposal_params[:applied_date] = Date.parse(applied_date.split(' - ').first)
        end

        assigned_date = proposal_params[:assigned_date]

        if assigned_date
          proposal_params[:assigned_date] = Date.parse(assigned_date.split(' - ').first)
        end
      end.compact
    end

    def update_ams_subject_codes
      if first_ams_subject_id
        first_ams_subject = ProposalAmsSubject.find_or_initialize_by(proposal: proposal, code: 'code1')
        first_ams_subject.ams_subject_id = first_ams_subject_id
        first_ams_subject.save!
      end

      if second_ams_subject_id
        second_ams_subject = ProposalAmsSubject.find_or_initialize_by(proposal: proposal, code: 'code2')
        second_ams_subject.ams_subject_id = second_ams_subject_id
        second_ams_subject.save!
      end
    end

    def first_ams_subject_id
      params.dig(:ams_subjects, :code1)
    end

    def second_ams_subject_id
      params.dig(:ams_subjects, :code2)
    end

    def submit_proposal
      submission.save_answers
    end

    def submission
      @submission ||= SubmitProposalService.new(proposal, params)
    end
  end
end
