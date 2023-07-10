class PeopleController < ApplicationController
  before_action :set_person
  layout('devise')

  def new
    @invited_as = invite&.invited_as
    @proposal = invite&.proposal
    @response = params[:response]

    redirect_to root_path, alert: t('people.new.alert') unless @person
  end

  def update
    if @person.update(person_params)
      if @person.demographic_survey_submitted?
        redirect_to root_path
      else
        redirect_to new_survey_path(code: params[:code], response: params[:response]),
                    notice: t('people.update.success')
      end
    else
      @invited_as = invite&.invited_as
      render :new
    end
  end

  def show_person_modal
    @proposal = Proposal.find(params[:id])
    @person = @proposal.lead_organizer

    render partial: 'submitted_proposals/person_modal', locals: { person: @person, proposal: @proposal }
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def update_lead_organizer
    @proposal = Proposal.find(params[:id])
    @person = Person.find(params[:person_id])
    @person.firstname = params['person']['firstname']
    @person.lastname = params['person']['lastname']
    @person.email = params['person']['email']
    @person.affiliation = params['person']['affiliation']
    if @person.save(validate: false)
      redirect_to edit_submitted_proposal_path(@proposal.id), notice: t('people.update_lead_organizer.success')
    else
      redirect_to edit_submitted_proposal_path(@proposal.id), alert: t('people.update_lead_organizer.failure')
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  private

  def person_params
    params.require(:person).permit(:firstname, :lastname, :affiliation, :department, :academic_status,
                                   :title, :first_phd_year, :country, :region,
                                   :city, :street_1, :street_2, :postal_code,
                                   :other_academic_status, :province, :state)
  end

  def set_person
    @person = invited_person || current_user&.person
  end

  def invite
    Invite.safe_find(code: params[:code])
  end

  def invited_person
    invite&.person
  end
end
