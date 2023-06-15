class SurveyController < ApplicationController
  before_action :set_invite, only: %i[new survey_questionnaire submit_survey]
  layout('devise')

  def new; end

  def survey_questionnaire; end

  def faqs
    @faqs = Faq.all
  end

  def submit_survey
    demographic_data = new_demographic_data(DemographicData.new)
    if demographic_data.save
      return if session[:is_invited_person] && !check_params

      post_demographic_form_path
    else
      redirect_to survey_questionnaire_survey_index_path(code: @invite&.code),
                  alert: demographic_data.errors.full_messages.join(', ')
    end
  end

  private

  def check_params
    invite_response_save if @invite && params[:response].present?

    if @invite.nil?
      redirect_to root_path, alert: t('survey.check_params.alert_first')
      return false
    elsif params[:response].empty?
      redirect_to root_path, alert: t('survey.check_params.alert')
      return false
    end
    true
  end

  def new_demographic_data(demographic_data)
    demographic_data.result = questionnaire_answers
    demographic_data.person = current_user&.person || @invite&.person
    demographic_data
  end

  def questionnaire_answers
    answers = questionnaire_params
    questionnaire_params.each do |key, value|
      if value.is_a?(Array) && value.any? { |answr| answr.match?(/^Prefer not/) }
        answers[key] = ['Prefer not to answer (Please note: If you choose this response, none of your other responses to this question will be considered in the data analysis.)']
      elsif value.is_a?(String) && value.match?(/^Prefer not/)
        answers[key] = 'Prefer not to answer (Please note: If you choose this response, none of your other responses to this question will be considered in the data analysis.)'
      end
    end

    answers
  end

  def questionnaire_params
    params.require(:survey)
  end

  def set_invite
    @invite = Invite.find_by(code: invite_code)
  end

  def invite_code
    params.permit([:code])&.[](:code)
  end

  def invite_response_save
    @invite.response = params[:response]
    @invite.status = 'confirmed' unless @invite.no?
    return unless @invite.save

    create_role
    send_email_on_response
  end

  def create_role
    return if @invite.no?

    proposal_role
    create_user if @invite.invited_as == 'Organizer' && !@invite.person.user
  end

  def send_email_on_response
    return if @invite.no?

    @organizers = @invite.proposal.supporting_organizers.remove(@invite.person&.fullname)
    InviteMailer.with(invite: @invite, organizers: @organizers)
                .invite_acceptance.deliver_later
  end

  def proposal_role
    role = Role.find_or_create_by!(name: @invite.invited_as)
    @invite.proposal.proposal_roles.create(role: role, person: @invite.person)
  end

  def create_user
    user = User.new(email: @invite.person.email,
                    password: SecureRandom.urlsafe_base64(20), confirmed_at: Time.zone.now)
    user.person = @invite.person
    user.save
  end

  def post_demographic_form_path
    message = 'Thank you for filling out our form! '

    if @invite.blank?
      redirect_to new_proposal_path, notice: message
    elsif organizer_without_account?
      message << ' If you wish to login to see the proposal being drafted,
                  please setup an account.'.squish
      redirect_to new_user_registration_path, notice: message
    elsif organizer_with_account?
      message << ' If you wish to login to
                  see the proposal being drafted, please set a password for your
                  account'.squish
      reset_password_token(@invite.person.user)
      redirect_to edit_password_url(@invite.person.user,
                                    reset_password_token: @token),
                  notice: message
    else
      message << ' We will contact you with the next steps, after the
                 peer-review process is complete.'.squish
      redirect_to root_path, notice: message
    end
  end

  def organizer_without_account?
    @invite.invited_as == 'Organizer' &&
      (@invite.person_id.blank? || @invite.person.user.nil?)
  end

  def organizer_with_account?
    @invite.invited_as == 'Organizer' && @invite&.person&.user.present?
  end

  def reset_password_token(user)
    @token, hashed = Devise.token_generator.generate(User, :reset_password_token)
    user.update(reset_password_token: hashed, reset_password_sent_at: Time.zone.now)
  end
end
