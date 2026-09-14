class ProposalFormsController < ApplicationController
  load_and_authorize_resource
  before_action :set_proposal_type
  before_action :set_proposal_form, only: %i[edit update show clone
                                             proposal_field]

  def index
    @proposal_forms = @proposal_type.proposal_forms
  end

  def new
    @stale_drafts = stale_drafts_for(@proposal_type)
    @proposal_form = ProposalForm.new
  end

  def edit
    return unless @proposal_form.active?
    return if params[:cloned]

    @proposal_form.update(status: :inactive)
    form = @proposal_form.deep_clone include: { proposal_fields:
                                                %i[options validations] }
    form.status = :active
    form.save

    redirect_to edit_proposal_type_proposal_form_path(@proposal_type, form, cloned: true)
  end

  def show
    redirect_to :index if @proposal_form.nil?
  end

  def update
    if @proposal_form.update(proposal_form_params)
      version_update_form
      redirect_to proposal_type_proposal_form_path(@proposal_type,
                                                   @proposal_form),
                  notice: t('proposal_forms.update.success')
    else
      redirect_to edit_proposal_type_proposal_form_path,
                  status: :unprocessable_entity,
                  alert: t('proposal_forms.update.failure')
    end
  end

  def create
    version_form_create
    if @proposal_form.save
      redirect_to proposal_type_proposal_forms_path,
                  notice: t('proposal_forms.create.success')
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
    lock_stale_drafts_for(@proposal_type)
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
                  notice: t('proposal_forms.update.success')
    else
      redirect_to edit_proposal_type_proposal_form_path,
                  status: :unprocessable_entity,
                  alert: t('proposal_forms.update.failure')
    end
  end

  def highest_version
    @proposal_type.proposal_forms.maximum(:version).to_i
  end

  def version_update_form
    version = @proposal_form.version + 1
    @proposal_form.update(version: version) if @proposal_form.active?
  end

  def version_form_create
    @proposal_form = ProposalForm.new(proposal_form_params)
    lock_stale_drafts_for(@proposal_form.proposal_type)
    forms = @proposal_form.proposal_type.proposal_forms.where(status:
                                                              %i[active draft])
    forms.update_all(status: :inactive) # rubocop:disable Rails/SkipsModelValidations
    @proposal_form.created_by = current_user
    @proposal_form.version = highest_version
  end

  def lock_stale_drafts_for(proposal_type)
    active_form = proposal_type.proposal_forms.find_by(status: :active)
    return unless active_form
    Proposal.draft.where(proposal_form_id: active_form.id)
            .update_all(status: Proposal.statuses[:locked])
  end

  def stale_drafts_for(proposal_type)
    active_form = proposal_type.proposal_forms.find_by(status: :active)
    return Proposal.none unless active_form
    Proposal.draft.where(proposal_form_id: active_form.id)
  end
end
