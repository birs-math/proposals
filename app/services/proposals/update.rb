# frozen_string_literal: true

module Proposals
  class Update
    include Callable

    MODEL_ATTRS = %i[title year subject_id ams_subject_ids location_ids
                  no_latex preamble bibliography cover_letter applied_date
                  same_week_as week_after assigned_date assigned_size]

    Result = Struct.new(:submission, :proposal, keyword_init: true) do
      def flash_errors
        return @flash_errors if defined?(@flash_errors)

        if errors?
          messages = { alert: [] }

          proposal.errors.full_messages.each do |error|
            messages[:alert] << error
          end

          submission.error_messages.each do |error|
            messages[:alert] << error.to_s
          end

          @flash_errors = messages
        else
          @flash_errors = {}
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
      ActiveRecord::Base.transaction do
        proposal.update(model_params.except(:year))
        update_year
        update_ams_subject_codes
        submit_proposal

        Result.new(submission: submission, proposal: proposal)
      rescue
        Result.new(submission: submission, proposal: proposal)
      end
    end

    private

    attr_reader :proposal, :params, :current_user

    def model_params
      @model_params ||= params.slice(MODEL_ATTRS).tap do |proposal_params|
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
      if limit_per_type_per_year_exhausted?
        proposal.errors.add(
          :year,
          I18n.t('proposals.limit_per_type_per_year', proposal_type: proposal.proposal_type.name)
        )
      else
        proposal.update(year: model_params[:year])
      end
    end

    def limit_per_type_per_year_exhausted?
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
      first_ams_subject = ProposalAmsSubject.find_or_initialize_by(proposal: proposal, code: 'code1')
      first_ams_subject.ams_subject_id = params.dig(:ams_subjects, :code1)
      first_ams_subject.save!

      second_ams_subject = ProposalAmsSubject.find_or_initialize_by(proposal: proposal, code: 'code2')
      second_ams_subject.ams_subject_id = params.dig(:ams_subjects, :code2)
      second_ams_subject.save!
    end

    def submit_proposal
      submission.save_answers
    end

    def submission
      @submission ||= SubmitProposalService.new(proposal, params)
    end
  end
end
