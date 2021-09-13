class ProposalFormsController < ApplicationController
  load_and_authorize_resource
  before_action :set_proposal_type
  before_action :set_proposal_form, only: %i[edit update show clone
                                             proposal_field]

  def index
    @proposal_forms = @proposal_type&.proposal_forms
  end

  def new
    forms = @proposal_type.proposal_forms.where(status: %i[active draft])
    forms.update_all(status: :inactive) # rubocop:disable Rails/SkipsModelValidations
    @proposal_form = ProposalForm.new
  end

  def edit; end

  def show
    redirect_to :index if @proposal_form.nil?
  end

  def update
    if @proposal_form.update(proposal_form_params)
      version = @proposal_form.version + 1
      @proposal_form.update(version: version) if @proposal_form.active?
      redirect_to proposal_type_proposal_form_path(@proposal_type,
                                                   @proposal_form),
                  notice: 'Proposal form was successfully updated'
    else
      redirect_to edit_proposal_type_proposal_form_path,
                  status: :unprocessable_entity,
                  alert: "Unable to update proposal form."
    end
  end

  def create
    @proposal_form = ProposalForm.new(proposal_form_params)
    forms = @proposal_form.proposal_type.proposal_forms.where(status:
                                                              %i[active draft])
    forms.update_all(status: :inactive) # rubocop:disable Rails/SkipsModelValidations
    @proposal_form.created_by = current_user
    @proposal_form.version = highest_version
    if @proposal_form.save
      redirect_to proposal_type_proposal_forms_path,
                  notice: 'Proposal form was successfully created!'
    else
      redirect_to new_proposal_type_proposal_form_path,
                  alert: "Title can't be blank"
    end
  end

  def proposal_field
    @proposal_field = ProposalField.find_by(id: params[:field_id])
    @proposal_field.destroy
    @proposal_field.fieldable.destroy
    redirect_to edit_proposal_type_proposal_form_path(@proposal_type,
                                                      @proposal_form)
  end

  def clone
    @proposal_type.proposal_forms.update_all(status: :inactive) # rubocop:disable Rails/SkipsModelValidations
    proposal_form = @proposal_form.deep_clone include:
                                  { proposal_fields: %i[options validations] }
    proposal_form.version = highest_version
    proposal_form.status = :draft
    proposal_form.proposal_type_id = params[:proposal_type_id]
    proposal_form.save
    redirect_to edit_proposal_type_proposal_form_path(@proposal_type,
                                                      proposal_form)
  end

  private

  def set_proposal_type
    @proposal_type = ProposalType.find_by(id: params[:proposal_type_id])
  end

  def set_proposal_form
    @proposal_form = ProposalForm.find_by(id: params[:id])
  end

  def proposal_form_params
    params.require(:proposal_form).permit(:title, :status, :introduction,
                                          :introduction2, :introduction3,
                                          :introduction_charts, :proposal_type_id)
          .merge(updated_by: current_user)
  end

  def update_proposal_form(form)
    if form.update(proposal_form_params)
      redirect_to edit_proposal_type_proposal_form_path,
                  notice: 'Proposal form was successfully updated'
    else
      redirect_to edit_proposal_type_proposal_form_path,
                  status: :unprocessable_entity,
                  alert: "Unable to update proposal form."
    end
  end

  def highest_version
    @proposal_type.proposal_forms.maximum(:version).to_i
  end
end
