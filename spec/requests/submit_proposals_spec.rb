require 'rails_helper'

RSpec.describe "/submit_proposals", type: :request do
  let(:proposal_type) { create(:proposal_type) }
  let(:proposal) { create(:proposal, proposal_type: proposal_type) }
  let(:subject_category) { create(:subject_category) }
  let(:subject) { create(:subject, subject_category_id: subject_category.id) }
  let(:ams_subjects) do
    create_list(:ams_subject, 2, subject_category_ids: subject_category.id,
                subject_id: subject.id)
  end
  let(:location) { create(:location) }

  before do
    person = create(:person, :with_proposals)
    prop = person.proposals.first
    authenticate_for_controllers(person, 'lead_organizer')
    expect(person.user.lead_organizer?(prop)).to be_truthy
  end

  describe "GET /new" do
    before { get new_submit_proposal_path }
    it { expect(response).to have_http_status(:ok) }
  end

  describe "POST /create without invite" do
    let(:invites_attributes) do
      {
        '0' => { firstname: 'First', lastname: 'Organizer',
                 deadline_date: DateTime.now, invited_as: 'Organizer' }
      }
    end

    let(:person) { user.person }
    let(:role) { user_role.role }
    let(:proposal_role) { create(:proposal_role, role: role, proposal: proposal, person: person) }
    let(:role_name) { 'Staff' }
    let(:user) { create(:user) }
    let(:role_privilege) do
      create(:role_privilege,
             permission_type: 'Manage', privilege_name: 'SubmitProposalsController', role_id: role.id)
      create(:role_privilege,
             permission_type: 'Manage', privilege_name: 'SubmittedProposalsController', role_id: role.id)
      create(:role_privilege,
             permission_type: 'Manage', privilege_name: 'ProposalsController', role_id: role.id)
    end

    let(:params) do
      { proposal: proposal.id, title: 'Test proposal', year: Date.today.year, assigned_date: Date.today, applied_date: Date.today,
        subject_id: subject.id,
        ams_subjects: { code1: ams_subjects.first.id,
                        code2: ams_subjects.last.id },
        invites_attributes: invites_attributes,
        location_ids: location.id, no_latex: false }
    end

    let(:http_referer) { nil }

    before do
      role_privilege
      proposal_role
      user_role
      sign_in user

      post submit_proposals_url, params: params, headers: { 'HTTP_REFERER' => http_referer }
    end

    describe 'POST #create' do
      let(:user_role) { create(:user_role, role: create(:role, name: role_name), user: user) }
      let(:role_name) { 'Staff' }

      it 'will not create invite' do
        expect(proposal.invites.count).to eq(0)
      end

      it 'updates the proposal' do
        proposal.reload
        expect(proposal.title).to eq('Test proposal')
        expect(proposal.year).to eq(Date.today.year)
        expect(proposal.assigned_date).to eq(Date.today)
        expect(proposal.applied_date).to eq(Date.today)
        expect(proposal.subject_id).to eq(subject.id)
        expect(proposal.location_ids).to eq([location.id])
        expect(proposal.ams_subjects).to eq(ams_subjects)
        expect(proposal.no_latex).to eq(false)
      end
    end

    describe 'redirects' do
      let(:user_role) { create(:user_role, role: create(:role, name: role_name), user: user) }

      context 'when referrer is not present' do
        let(:role_name) { 'lead_organizer' }

        it('uses fallback location') { expect(response).to redirect_to(edit_proposal_path(proposal)) }
      end

      context 'when referrer is set' do
        let(:role_name) { 'Staff' }
        let(:http_referer) { edit_submitted_proposal_path(proposal) }

        it('redirects to referer') { expect(response).to redirect_to(http_referer) }
      end
    end

    context 'when user exceeds proposal type per year limit' do
      let(:user_role) { create(:user_role, role: create(:role, name: role_name), user: user) }
      let(:role_name) { 'lead_organizer' }
      let(:old_proposal) do
        create(:proposal, proposal_type: proposal.proposal_type, year: params[:year], status: :submitted)
      end

      before do
        create(:proposal_role, proposal: old_proposal, role: role, person: user.person)

        post submit_proposals_url, params: params
      end

      it 'will alert' do
        expect(flash[:alert])
          .to eq(["Year #{I18n.t('proposals.limit_per_type_per_year', proposal_type: proposal.proposal_type.name)}"])
      end
    end
  end

  describe "POST #create_invite with invite parameters" do
    let(:invites_attributes) do
      { '0' => { firstname: 'First', lastname: 'Organizer',
                 email: 'organizer@gmail.com', deadline_date: DateTime.now,
                 invited_as: 'Organizer' } }
    end
    let(:params) do
      { proposal: proposal.id, title: 'Test proposal', year: '2023',
        subject_id: subject.id, ams_subjects: { code1: ams_subjects.first.id, code2: ams_subjects.second.id },
        invites_attributes: invites_attributes,
        location_ids: location.id, no_latex: false }
    end

    context 'with valid invite params, as lead organizer' do
      let!(:proposal) { build :proposal, proposal_type: proposal_type, is_submission: true}

      before do
        @prop = @person.proposals.first
        expect(@person.user.lead_organizer?(@prop)).to be_truthy
        @invites_count = @prop.invites.count
        @submission = SubmitProposalService.new(proposal,params)

        post create_invite_submit_proposals_url, params: params.merge(proposal: @prop.id), xhr: true
      end

      it { expect(response).to have_http_status(:ok) }

      it "updates the proposal invites count" do
        expect(@prop.invites.count).to eq(@invites_count + 1)
      end
    end

    context 'with valid invite params, not as lead organizer' do
      before do
        expect(proposal.invites.count).to eq(0)

        post create_invite_submit_proposals_url, params: params, xhr: true
      end

      it { expect(response).to have_http_status(:forbidden) }

      it "does not update the proposal invites count" do
        expect(proposal.invites.count).to eq(0)
      end
    end

    context 'with invalid invite params, not as lead organizer' do
      before do
        proposal.invites.new(invites_attributes['0']).save
        expect(proposal.invites.count).to eq(1)

        post create_invite_submit_proposals_url, params: params, xhr: true
      end

      it { expect(response).to have_http_status(:forbidden) }

      it "does not update the proposal invites count" do
        expect(proposal.invites.count).to eq(1)
      end
    end
  end

  describe "GET /thanks" do
    it "render a successful response" do
      get thanks_submit_proposals_url
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /invitation_template" do
    let(:proposal_role) { create(:proposal_role, proposal: proposal) }

    context "when params contain organizer" do
      let(:params) do
        {
          invited_as: 'organizer',
          proposal: proposal.id
        }
      end
      let(:email_template) { create(:email_template) }

      before do
        proposal_role.role.update(name: 'lead_organizer')
        email_template.update(email_type: "organizer_invitation_type")
        post invitation_template_submit_proposals_url, params: params
      end

      it "render a successful response" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "when params contain participant" do
      let(:params) do
        {
          invited_as: 'participant',
          proposal: proposal.id
        }
      end
      let(:email_template) { create(:email_template) }

      before do
        proposal_role.role.update(name: 'lead_organizer')
        email_template.update(email_type: "participant_invitation_type")
        post invitation_template_submit_proposals_url, params: params
      end

      it "render a successful response" do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
