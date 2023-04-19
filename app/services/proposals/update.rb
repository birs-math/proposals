# frozen_string_literal: true

module Proposals
  class Update
    include Callable

    MODEL_ATTRS = %i[title year subject_id ams_subject_ids location_ids
                  no_latex preamble bibliography cover_letter applied_date
                  same_week_as week_after assigned_date assigned_size]

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
        proposal.update(model_params.except(:year))
        update_year
        update_ams_subject_codes
        submit_proposal
      end
    end

    def model_params
      @model_params ||= params.slice(*MODEL_ATTRS).tap do |proposal_params|
        applied_date = proposal_params[:applied_date]

        if applied_date
          proposal_params[:applied_date] = Date.parse(applied_date.split(' - ').first)
        end

        assigned_date = proposal_params[:assigned_date]

        if assigned_date
          proposal_params[:assigned_date] = Date.parse(assigned_date.split(' - ').first)
        end
      end
    end

    def update_year
      if limit_per_type_per_year_exceeded?
        proposal.errors.add(
          :base,
          I18n.t('proposals.limit_per_type_per_year', proposal_type: proposal.proposal_type.name)
        )
      else
        proposal.update(year: model_params[:year])
      end
    end

    def limit_per_type_per_year_exceeded?
      return @exists_query_result if defined?(@exists_query_result)

      current_user_proposal_ids = ProposalRole.joins(:role, :person)
        .where(roles: { name: 'lead_organizer' }, person: { id: current_user.person.id })
        .pluck(:proposal_id)

      @exists_query_result = Proposal.exists?(
        proposal_type_id: proposal.proposal_type_id,
        year: model_params[:year],
        id: current_user_proposal_ids
      )
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
