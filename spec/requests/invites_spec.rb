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

  before do
    role_privilege
    user.roles << role
    sign_in user
  end

  describe "POST /inviter_response" do
    before do
      params = {
        proposal_id: proposal.id,
        id: invite.id,
        code: invite.code,
        commit: commit
      }
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
  end

  describe "GET /show" do
    context 'when invite is empty' do
      before do
        get invite_path(code: '')
      end
      it { expect(response).to redirect_to(root_path) }
    end

    context 'when status is pending' do
      before do
        get invite_path(code: invite1.code)
      end
      let(:invite1) { create(:invite, status: 'pending') }
      it { expect(response).to have_http_status(:ok) }
    end

    context 'when status is confirmed' do
      before do
        get invite_path(code: invite1.code)
      end
      let(:invite1) { create(:invite, status: 'confirmed') }
      it { expect(response).to redirect_to(root_path) }
    end

    context 'when status is cancelled' do
      before do
        get invite_path(code: invite1.code)
      end
      let(:invite1) { create(:invite, status: 'cancelled') }
      it { expect(response).to redirect_to(cancelled_path) }
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
    let(:proposal_role) { create(:proposal_role, person: invite.person, proposal: invite.proposal) }
    let(:invite1) { create(:invite, status: 'cancelled') }
    before do
      authenticate_for_controllers
      proposal_role.role.update(name: "Organizer")
      invite.person.proposal_roles << proposal_role
      role.update(name: role_user.name)
      post cancel_confirmed_invite_path(code: invite.code), params: { invite: invite1 }
    end

    context 'when current user is staff member' do
      let(:role_user) { create(:role, name: 'Staff') }
      it "updates the invite status" do
        expect(invite1.reload.status).to eq('cancelled')
        expect(response).to redirect_to(edit_submitted_proposal_path(invite.proposal))
      end
    end

    context 'when current user is not staff member' do
      let(:role_user) { create(:role, name: 'lead_organizer') }
      it "updates the invite status" do
        expect(invite1.reload.status).to eq('cancelled')
        expect(response).to redirect_to(edit_proposal_path(invite.proposal))
      end
    end
  end

  describe "POST /new_invite" do
    let(:invite1) { create(:invite, status: 'pending') }
    before do
      authenticate_for_controllers
      role.update(name: role_user.name)
      post new_invite_proposal_invite_path(id: invite.id, code: invite.code, proposal_id: proposal.id),
           params: { invite: invite1 }
    end

    context 'when current user is staff member' do
      let(:role_user) { create(:role, name: 'Staff') }
      it "updates the invite status" do
        expect(invite1.reload.status).to eq('pending')
        expect(response).to redirect_to(edit_submitted_proposal_path(invite.proposal))
      end
    end

    context 'when current user is not staff member' do
      let(:role_user) { create(:role, name: 'lead_organizer') }
      it "updates the invite status" do
        expect(invite1.reload.status).to eq('pending')
        expect(response).to redirect_to(edit_proposal_path(invite.proposal))
      end
    end
  end

  describe "POST /invite_email" do
    context 'when id in params is 0' do
      before do
        authenticate_for_controllers
        params = {
          proposal_id: proposal.id,
          id: 0,
          code: invite.code,
          invited_as: "Participant",
          body: "Send email to participant for proposal invitation."
        }
        post invite_email_proposal_invite_path(params)
      end
      it "send invite email" do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when id in params is not 0' do
      before do
        authenticate_for_controllers
        params = {
          proposal_id: proposal.id,
          id: invite.id,
          code: invite.code,
          invited_as: "Participant",
          body: "Send email to participant for proposal invitation."
        }
        post invite_email_proposal_invite_path(params)
      end
      it "send invite email" do
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /inviter_reminder with staff member" do
    before do
      authenticate_for_controllers
      role.update(name: role_user.name)
      params = { proposal_id: proposal.id, id: invite1.id, code: invite1.code }
      post invite_reminder_proposal_invite_path(params)
    end

    context 'when status is pending' do
      let(:invite1) { create(:invite, status: 'pending') }
      let(:role_user) { create(:role, name: 'Staff') }
      it "sends invite reminder when invite status is pending" do
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(edit_submitted_proposal_url(proposal.id))
      end
    end

    context 'when status is confirmed' do
      let(:invite1) { create(:invite, status: 'confirmed') }
      let(:role_user) { create(:role, name: 'Staff') }
      it "does not send invite reminder when invite status is pending" do
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(edit_proposal_path(proposal.id))
      end
    end
  end

  describe "POST /inviter_reminder without staff member" do
    before do
      authenticate_for_controllers
      role.update(name: role_user.name)
      params = { proposal_id: proposal.id, id: invite1.id, code: invite1.code }
      post invite_reminder_proposal_invite_path(params)
    end

    context 'when status is pending' do
      let(:invite1) { create(:invite, status: 'pending') }
      let(:role_user) { create(:role, name: 'lead_organizer') }
      it "sends invite reminder when invite status is pending" do
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(edit_proposal_url(proposal.id))
      end
    end

    context 'when status is confirmed' do
      let(:invite1) { create(:invite, status: 'confirmed') }
      let(:role_user) { create(:role, name: 'lead_organizer') }
      it "does not send invite reminder when invite status is pending" do
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(edit_proposal_path(proposal.id))
      end
    end
  end
end
