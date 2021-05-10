class ProposalFormsController < ApplicationController
  before_action :set_proposal_form, only: %i[edit update show destroy clone]

  def index
    @proposal_forms = ProposalForm.all
  end

  def index
    @proposal_forms = ProposalForm.all
  end

  def new
    @proposal_form = ProposalForm.new
  end

  def edit; end

  def show
    redirect_to :index if @proposal_form.nil?
  end

  def update
    if @proposal_form.update(proposal_form_params)
      redirect_to @proposal_form, notice: 'Proposal form was successfully updated'
    else
      render :edit, status: :unprocessable_entity,
                    error: "Unable to update proposal form."
    end
  end

  def create
    @proposal_form = ProposalForm.new(proposal_form_params)
    @proposal_form.created_by = current_user
    if @proposal_form.save
      redirect_to edit_proposal_form_path(@proposal_form)
    else
      render :new, error: 'Error saving proposal'
    end
  end

  def destroy
    @proposal_form.destroy
    respond_to do |format|
      format.html { redirect_to proposal_forms_url, notice: "Proposal form was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def clone
    proposal_form = @proposal_form.dup
    proposal_form.proposal_fields << @proposal_form.proposal_fields
    proposal_form.status = 'draft'
    proposal_form.save
    redirect_to edit_proposal_form_path(proposal_form)
  end

  private

  def set_proposal_form
    @proposal_form = ProposalForm.find_by(id: params[:id])
  end

  def proposal_form_params
    params.require(:proposal_form).permit(:title, :status, :proposal_type_id).merge(updated_by: current_user)
  end
end
