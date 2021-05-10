require 'rails_helper'

RSpec.describe "/proposal_forms", type: :request do
  let(:proposal_form) { create(:proposal_form, status: 'draft') }

  describe "GET /index" do
    it "renders a successful response" do
      get proposal_forms_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new" do
    before do
      get new_proposal_form_url
    end
    it { expect(response).to have_http_status(:ok) }
  end

  describe "POST /create" do
    let(:proposal_type) { create(:proposal_type) }

    it "creates a new proposal_form" do
      authenticate_for_controllers

      expect do
        post proposal_forms_url(proposal_type: proposal_type)
      end.to change(ProposalForm, :count).by(1)
    end
  end

  describe "GET /show" do
    before do
      get proposal_form_url(proposal_form)
    end

    it { expect(response).to have_http_status(:ok) }
  end

  describe "GET /edit" do
    it "render a successful response" do
      get edit_proposal_form_url(proposal_form)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update" do
    let(:params) do { proposal_form: {status: 'active'}} end
    before do
      authenticate_for_controllers
      patch proposal_form_url(proposal_form, params: params)
    end

    it "updates the status to active" do
      expect(proposal_form.reload.status).to eq('active')
    end
    it {expect(proposal_form.reload.updated_by).to eq(@user)}
  end

  describe "DELETE /destroy" do
    before do
      delete proposal_form_url(proposal_form.id)
    end

    it { expect(ProposalForm.all.count).to eq(0) }
  end

  describe "POST /clone" do
    before do
      post clone_proposal_form_path(proposal_form)
    end

    it { expect(response).to redirect_to(edit_proposal_form_path(ProposalForm.last)) }
  end
end
