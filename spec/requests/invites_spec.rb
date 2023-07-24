require 'rails_helper'

RSpec.describe "/proposals/:proposal_id/invites", type: :request do
  let(:proposal_type) { create(:proposal_type) }
  let(:proposal) { create(:proposal, proposal_type: proposal_type) }
  let(:invite) { create(:invite, proposal: proposal) }
  let(:person) { create(:person) }
  let(:role) { create(:role, name: 'Staff') }
  let(:user) { create(:user, person: person) }
  let(:role_privilege) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "Invite", role_id: role.id)
  end
  let(:role_privilege1) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "SubmittedProposalsController", role_id: role.id)
  end
  let(:deadline) { DateTime.current }

  before do
    role_privilege
    user.roles << role
    sign_in user
  end

  describe "POST /inviter_response" do
    let(:params) do
      {
        proposal_id: proposal.id,
        id: invite.id,
        code: invite.code,
        commit: commit
      }
    end

    before do
      post inviter_response_proposal_invite_path(params)
    end

    context 'when response is invalid' do
      let(:commit) { 'Ok' }

      it { expect(response).to redirect_to(invite_url(code: invite.code)) }
    end

    context 'when response is no' do
      let(:commit) { 'No' }

      it { expect(response).to have_http_status(:found) }
    end

    context 'when deadline' do
      let(:commit) { 'Yes' }
      let(:invite) do
        create(:invite, proposal: proposal, response: 'maybe', status: 'pending', deadline_date: deadline)
      end

      before do
        invite.reload
      end

      context 'is today' do
        let(:deadline) { DateTime.current }

        it { expect(response).to redirect_to(new_person_path(code: invite.code, response: 'yes')) }
      end

      context 'is tomorrow' do
        let(:deadline) { DateTime.current + 1.day }

        it { expect(response).to redirect_to(new_person_path(code: invite.code, response: 'yes')) }
      end

      context 'was yesterday' do
        before do
          invite.update_attribute(:deadline_date, DateTime.current - 1.day )

          post inviter_response_proposal_invite_path(params)
        end

        it { expect(response).to have_rendered(:invalid_code) }
      end
    end
  end

  describe "GET /show" do
    before { get invite_path(code: code) }

    let(:new_invite) { create(:invite, status: status) }
    let(:code) { new_invite.code }

    context 'when invite is empty' do
      let(:code) { '' }

      it { expect(response).to have_rendered(:invalid_code) }
    end

    context 'when status is pending' do
      let(:status) { 'pending' }

      it { expect(response).to have_http_status(:ok) }
    end

    context 'when status is confirmed' do
      let(:status) { 'confirmed' }

      it { expect(response).to redirect_to(root_path) }
    end

    context 'when status is cancelled' do
      let(:status) { 'cancelled' }

      it { expect(response).to have_rendered(:invalid_code) }
    end

    context 'when deadline' do
      let(:invite) do
        create(:invite, proposal: proposal, status: 'pending', response: 'maybe', deadline_date: deadline)
      end
      let(:code) { invite.code }

      context 'is today' do
        let(:deadline) { DateTime.current }

        it { expect(response).to have_http_status(:ok) }
      end

      context 'is tomorrow' do
        let(:deadline) { DateTime.current + 1.day }

        it { expect(response).to have_http_status(:ok) }
      end

      context 'was yesterday' do
        before do
          invite.update_attribute(:deadline_date, DateTime.current - 1.day )

          get invite_path(code: code)
        end

        it { expect(response).to have_rendered(:invalid_code) }
      end
    end
  end

  describe "GET /thanks" do
    it "render a successful response" do
      get thanks_proposal_invites_url(invite.proposal)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /cancelled" do
    it "render a message when an invite has been cancelled" do
      get cancelled_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /show_invite_modal" do
    it "open a modal and response should be ok" do
      get show_invite_modal_url(invite.id)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update" do
    let(:params) do
      {
        invite: {
          firstname: "Test FirstName",
          lastname: "Test LastName",
          affiliation: "Test Affiliation"
        }
      }
    end
    it "update invite data from params" do
      patch proposal_invite_url(proposal.id, invite.id), params: params
      expect(response).to have_http_status(302)
    end
  end

  describe "POST /cancel" do
    context 'when deadline_date is less than current date' do
      let(:invite1) { create(:invite, status: 'cancelled', deadline_date: Time.zone.now) }
      before do
        authenticate_for_controllers
        invite1.skip_deadline_validation = true
        post cancel_path(code: invite1.code)
      end

      it "skips deadline validation" do
        expect(response).to have_http_status(:found)
      end
    end

    context 'when current user is staff member' do
      let(:invite1) { create(:invite, status: 'cancelled') }

      before do
        authenticate_for_controllers
        role.update(name: 'Staff')
        post cancel_path(code: invite.code), params: { invite: invite1 }
      end

      it "updates the invite status" do
        expect(invite1.reload.status).to eq('cancelled')
        expect(response).to redirect_to(edit_submitted_proposal_url(invite.proposal))
      end
    end

    context 'when current user is not staff member' do
      let(:invite1) { create(:invite, status: 'cancelled') }

      before do
        authenticate_for_controllers
        role.update(name: 'lead_organizer')
        post cancel_path(code: invite.code), params: { invite: invite1 }
      end

      it "updates the invite status" do
        expect(invite1.reload.status).to eq('cancelled')
        expect(response).to redirect_to(edit_proposal_path(invite.proposal))
      end
    end
  end

  describe "POST /cancel_confirmed_invite" do
    let(:proposal_role) { create(:proposal_role, person: person, proposal: invite.proposal) }
    let(:person) { invite.person }

    before do
      authenticate_for_controllers(person)
      proposal_role.role.update(name: "Organizer")
      person.proposal_roles << proposal_role
      role.update(name: role_name)

      post cancel_confirmed_invite_path(code: invite.code), params: { invite: invite }
    end

    context 'when current user is staff member' do
      let(:role_name) { 'Staff' }

      it { expect(user.staff_member?).to be_truthy }

      it "updates the invite status" do
        expect(invite.reload.status).to eq('cancelled')
        expect(response).to redirect_to(edit_submitted_proposal_path(invite.proposal))
      end
    end

    context 'when current user is not staff member' do
      let(:role_name) { 'lead_organizer' }

      it { expect(user.staff_member?).to be_falsey }

      it "updates the invite status" do
        expect(invite.reload.status).to eq('cancelled')
        expect(response).to redirect_to(edit_proposal_path(invite.proposal))
      end
    end
  end

  describe "POST /new_invite" do
    before do
      authenticate_for_controllers
      role.update(name: role_name)
      post new_invite_proposal_invite_path(id: invite.id, code: invite.code, proposal_id: proposal.id),
           params: { invite: invite }
    end

    context 'when current user is staff member' do
      let(:role_name) { 'Staff' }

      it "updates the invite status" do
        expect(invite.reload.status).to eq('pending')
        expect(response).to redirect_to(edit_submitted_proposal_path(invite.proposal))
      end
    end

    context 'when current user is not staff member' do
      let(:role_name) { 'lead_organizer' }

      it "updates the invite status" do
        expect(invite.reload.status).to eq('pending')
        expect(response).to redirect_to(edit_proposal_path(invite.proposal))
      end
    end
  end

  describe "POST /inviter_reminder with staff member" do
    before do
      authenticate_for_controllers
      role.update(name: role_name)
      params = { proposal_id: proposal.id, id: invite1.id, code: invite1.code }
      post invite_reminder_proposal_invite_path(params)
    end

    context 'when status is pending' do
      let(:invite1) { create(:invite, status: 'pending') }
      let(:role_name) { 'Staff' }
      it "sends invite reminder when invite status is pending" do
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(edit_submitted_proposal_url(proposal))
      end
    end

    context 'when status is confirmed' do
      let(:invite1) { create(:invite, status: 'confirmed') }
      let(:role_name) { 'Staff' }
      it "does not send invite reminder when invite status is pending" do
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(edit_proposal_path(proposal))
      end
    end
  end

  describe "POST /inviter_reminder without staff member" do
    before do
      authenticate_for_controllers
      role.update(name: role_name)
      params = { proposal_id: proposal.id, id: invite1.id, code: invite1.code }
      post invite_reminder_proposal_invite_path(params)
    end

    context 'when status is pending' do
      let(:invite1) { create(:invite, status: 'pending') }
      let(:role_name) { 'lead_organizer' }
      it "sends invite reminder when invite status is pending" do
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(edit_proposal_url(proposal))
      end
    end

    context 'when status is confirmed' do
      let(:invite1) { create(:invite, status: 'confirmed') }
      let(:role_name) { 'lead_organizer' }
      it "does not send invite reminder when invite status is pending" do
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(edit_proposal_path(proposal))
      end
    end
  end
end
