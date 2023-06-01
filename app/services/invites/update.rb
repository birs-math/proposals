# frozen_string_literal: true

module Invites
  class Update

    MODEL_ATTRS = %i[firstname lastname email].freeze

    Result = Struct.new(:invite, keyword_init: true) do
      def success?
        invite.valid?
      end

      def flash_message
        if success?
          { notice: I18n.t('invites.update.success') }
        else
          { alert: invite.errors.full_messages || I18n.t('invites.update.failure') }
        end
      end
    end

    def initialize(invite:, params:)
      @invite = invite
      @params = params

      @invite.skip_deadline_validation = true if @invite.deadline_date < Date.current
    end

    def call
      ActiveRecord::Base.transaction do
        invite.update(model_params)
        invite.update_invited_person(params[:affiliation]) if params.key?(:affiliation)
      end

      Result.new(invite: invite)
    end

    private

    attr_reader :invite, :params

    def model_params
      @model_params ||= if params.respond_to?(:permit)
                          params.permit(*MODEL_ATTRS)
                        else
                          params.slice(*MODEL_ATTRS)
                        end
    end
  end
end
