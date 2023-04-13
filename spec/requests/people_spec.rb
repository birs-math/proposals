require 'rails_helper'

RSpec.describe "/person", type: :request do
  let(:proposal) { create(:proposal) }
  let(:invite) { create(:invite, proposal: proposal) }
  let(:person) { create(:person) }
  let(:role) { create(:role, name: 'Staff') }
  let(:user) { create(:user, person: person) }
  let(:role_privilege) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "Person", role_id: role.id)
  end

  describe "GET /new" do
    before do
      role_privilege
      user.roles << role
      sign_in user
    end

    it "renders a successful response" do
      get new_person_url(code: invite.code, response: 'yes')
      expect(response).to have_http_status(:ok)
    end

    it "renders a successful response when invite is not present" do
      get new_person_url(code: 'test', response: 'yes')
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'when user person is not present' do
    let(:user1) { create(:user, person: nil) }

    before do
      role_privilege
      user1.roles << role
      sign_in user1
    end

    it 'redirect to root_path when person is not present' do
      get new_person_url(code: 'test', response: 'yes')

      expect(response).to redirect_to(root_path)
    end
  end

  describe "PATCH /update" do
    before do
      role_privilege
      user.roles << role
      sign_in user
    end

    let(:person_params) do
      { department: 'computer_science' }
    end

    context "with valid parameters" do
      before do
        patch person_url(person), params: { person: person_params }
      end

      it "updates the requested Person" do
        expect(person.reload.department).to eq('computer_science')
      end
    end
  end

  describe "PATCH /update" do
    before do
      role_privilege
      user.roles << role
      sign_in user
    end

    let(:person_params) do
      { department: 'computer_science',
        firstname: nil }
    end

    context "with invalid parameters" do
      it "not updated the requested Person" do
        patch person_url(person), params: { person: person_params, code: invite.code }

        expect(person.reload.department).to eq(nil)
      end

      it "if invite is not present" do
        patch person_url(person), params: { person: person_params }

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /show_person_modal" do
    let!(:proposal) { create(:proposal) }
    let!(:proposal_roles) { create_list(:proposal_role, 3, proposal: proposal) }
    let!(:person) { proposal_roles.last.person }

    before do
      role_privilege
      user.roles << role
      sign_in user
      proposal_roles.last.role.update(name: 'lead_organizer')
    end
    it "renders a partial" do
      proposal
      person
      get show_person_modal_url(proposal.id)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update_lead_organizer" do
    let!(:proposal) { create(:proposal) }
    let!(:proposal_roles) { create_list(:proposal_role, 3, proposal: proposal) }
    let!(:person) { proposal_roles.last.person }
    let(:params) do
      {
        person_id: proposal_roles.last.person_id,
        person: {
          firstname: "Test FirstName",
          lastname: "Test LastName",
          email: "test email",
          affiliation: "Test Affiliation"
        }
      }
    end
    before do
      role_privilege
      user.roles << role
      sign_in user
    end
    it "redirect edit_submitted_proposal" do
      proposal
      person
      patch update_lead_organizer_url(proposal.id), params: params
      expect(response).to redirect_to(edit_submitted_proposal_url(proposal.id))
    end
  end

end
