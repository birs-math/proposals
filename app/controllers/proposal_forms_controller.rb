class ProposalFormsController < ApplicationController
  load_and_authorize_resource
  before_action :set_proposal_type
  before_action :set_proposal_form, only: %i[edit update show clone deactivate export_stale_drafts proposal_field]

  def index
    @proposal_forms = @proposal_type.proposal_forms
  end

  def new
    @proposal_form = ProposalForm.new
  end

  def edit
    return unless @proposal_form.active?
    return if params[:cloned]

    if draft_proposals_for(@proposal_form).any? && !params[:confirmed]
      @proposals_to_lock = draft_proposals_for(@proposal_form)
      @stale_count = @proposals_to_lock.count
      render :confirm_edit_clone
      return
    end

    lock_draft_proposals_for(@proposal_form)
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
    if deactivating? && draft_proposals_for(@proposal_form).any? && !params[:confirmed]
      @proposals_to_lock = draft_proposals_for(@proposal_form)
      @stale_count = @proposals_to_lock.count
      @pending_params = proposal_form_params
      @confirm_url = proposal_type_proposal_form_path(@proposal_type, @proposal_form)
      @confirm_method = :patch
      render :confirm_deactivate
      return
    end
    locked_count = deactivating? ? lock_draft_proposals_for(@proposal_form) : 0
    if @proposal_form.update(proposal_form_params)
      version_update_form
      notice = t('proposal_forms.update.success')
      notice += " #{t('proposal_forms.stale_drafts.locked_notice', count: locked_count)}" if locked_count > 0
      redirect_to proposal_type_proposal_form_path(@proposal_type,
                                                   @proposal_form),
                  notice: notice
    else
      redirect_to edit_proposal_type_proposal_form_path,
                  status: :unprocessable_entity,
                  alert: t('proposal_forms.update.failure')
    end
  end

  def deactivate
    if draft_proposals_for(@proposal_form).any? && !params[:confirmed]
      @proposals_to_lock = draft_proposals_for(@proposal_form)
      @stale_count = @proposals_to_lock.count
      @confirm_url = deactivate_proposal_type_proposal_form_path(@proposal_type, @proposal_form)
      @confirm_method = :patch
      render :confirm_deactivate
      return
    end
    locked_count = lock_draft_proposals_for(@proposal_form)
    @proposal_form.update!(status: :inactive)
    notice = t('proposal_forms.update.success')
    notice += " #{t('proposal_forms.stale_drafts.locked_notice', count: locked_count)}" if locked_count > 0
    redirect_to proposal_type_proposal_forms_path(@proposal_type), notice: notice
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

  def export_stale_drafts
    require 'csv'
    proposals = draft_proposals_for(@proposal_form).order(updated_at: :desc)
    csv_data = CSV.generate(headers: true) do |csv|
      csv << %w[Code Title Last\ Modified]
      proposals.each do |p|
        csv << [p.code, p.title, p.updated_at.strftime('%Y-%m-%d')]
      end
    end
    send_data csv_data,
              filename: "stale_drafts_form_#{@proposal_form.id}.csv",
              type: 'text/csv',
              disposition: 'attachment'
  end

  def clone
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
    @proposal_form.created_by = current_user
    @proposal_form.version = highest_version
  end

  def deactivating?
    proposal_form_params[:status] == 'inactive' && @proposal_form.active?
  end

  def draft_proposals_for(form)
    Proposal.draft.where(proposal_form_id: form.id)
  end

  def lock_draft_proposals_for(form)
    Proposal.draft.where(proposal_form_id: form.id)
            .update_all(status: Proposal.statuses[:locked])
  end
end
