require 'rails_helper'

RSpec.describe "/email_templates", type: :request do
  let(:email_template) { create(:email_template) }
  let(:person) { create(:person) }
  let(:role) { create(:role, name: 'Staff') }
  let(:user) { create(:user, person: person) }
  let(:role_privilege) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "EmailTemplate",
           role_id: role.id)
  end

  before do
    role_privilege
    user.roles << role
    sign_in user
  end

  describe "GET /index" do
    before do
      get email_templates_url
    end
    it { expect(response).to have_http_status(:ok) }
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_email_template_url
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:email_template_params) do
        { title: 'Quick response', subject: 'Mathematics', body: 'Testing body', email_type: 'reject_type' }
      end
      it "creates a new email_template" do
        expect do
          post email_templates_url, params: { email_template: email_template_params }
        end.to change(EmailTemplate, :count).by(1)
      end
    end

    context "with invalid parameters" do
      let(:email_template_params) do
        { title: '', subject: 'Mathematics', body: 'Testing body', email_type: 'reject_type' }
      end
      it "does not create a new email_template" do
        expect do
          post email_templates_url, params: { email_template: email_template_params }
        end.to change(EmailTemplate, :count).by(0)
      end
    end
  end

  describe "GET /show" do
    it "render a successful response" do
      get email_template_url(email_template)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /edit" do
    it "render a successful response" do
      get edit_email_template_url(email_template)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:email_template_params) do
        { title: 'Quick response', subject: 'Mathematics', body: 'Testing body', email_type: 'reject_type' }
      end
      before do
        patch email_template_url(email_template), params: { email_template: email_template_params }
      end
      it "updates the requested email_template" do
        expect(email_template.reload.subject).to eq('Mathematics')
      end
    end

    context "with invalid parameters" do
      let(:email_template_params) do
        { title: 'Quick response', subject: '', body: 'Testing body', email_type: 'reject_type' }
      end
      before do
        patch email_template_url(email_template), params: { email_template: email_template_params }
      end
      it "renders a successful response (i.e. to display the 'edit' template)" do
        expect(response).to redirect_to(edit_email_template_url(email_template))
      end
    end
  end

  describe "DELETE /destroy" do
    before { email_template }

    it { expect { delete(email_template_url(email_template.id)) }.to change(EmailTemplate, :count).by(-1) }
  end
end
