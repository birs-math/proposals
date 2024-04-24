class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, only: %i[index]
  before_action :person, only: %i[edit update demographic_data]

  def index
    if params[:email].present?
      @pagy, @profiles = pagy(Person.where('email ILIKE ?', "%#{params[:email]}%").order(id: :desc))
    else
      @pagy, @profiles = pagy(Person.order(id: :desc))
    end
  end

  def edit
    @result = @person&.demographic_data&.result || {}
  end

  def update
    if @person.update(person_params)
      update_user_email
      redirect_to edit_profile_path(person), notice: t('profile.update.success')
    else
      redirect_to edit_profile_path(person), alert: @person.errors.full_messages
    end
  end

  def demographic_data
    demographic_data = person.demographic_data || person.build_demographic_data
    demographic_data.result = questionnaire_answers

    if demographic_data.save
      redirect_to edit_profile_path(@person), notice: t('profile.demographic_data.success')
    else
      redirect_to edit_profile_path(@person)
    end
  end

  private

  def person_params
    params.require(:person).permit(:firstname, :lastname, :email, :affiliation,
                                   :department, :academic_status,
                                   :title, :first_phd_year, :country, :region,
                                   :city, :street_1, :street_2, :postal_code,
                                   :other_academic_status, :province, :state)
  end

  def questionnaire_answers
    params.require(:profile_survey)
  end

  def person
    @person ||= if params[:id] && current_user.staff_member?
                  Person.find(params[:id])
                else
                  current_user&.person
                end
  end

  def authorize_user
    raise CanCan::AccessDenied unless current_user.staff_member?
  end

  def update_user_email
    user = @person.user
    return unless user

    user.email = @person.email
    user.skip_reconfirmation!
    user.save!
  end
end
