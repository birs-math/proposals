class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :assign_ability, :set_current_user

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  def assign_ability
    @ability = Ability.new(current_user)
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html { redirect_to new_proposal_or_list(current_user), alert: exception.message }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
  end

  def set_current_user
    User.current = current_user
  end

  def new_proposal_or_list(user)
    user&.person&.proposals&.each do |proposal|
      return proposals_path if user&.organizer?(proposal)
    end
    new_proposal_path
  end

  def record_not_found
    respond_to do |format|
      format.js { render json: { errors: [I18n.t('errors.messages.resource_not_found')] }, status: 404 }
      format.html { redirect_to root_path, alert: I18n.t('errors.messages.resource_not_found') }
    end
  end

  def record_invalid
    respond_to do |format|
      format.js { render json: { errors: [I18n.t('errors.messages.something_went_wrong')] }, status: 404 }
      format.html { redirect_to :back, alert: I18n.t('errors.messages.something_went_wrong') }
    end
  end
end
