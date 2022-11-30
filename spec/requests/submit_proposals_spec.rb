require 'rails_helper'

RSpec.describe "/submit_proposals", type: :request do
  before do
    person = create(:person, :with_proposals)
    prop = person.proposals.first
    authenticate_for_controllers(person, 'lead_organizer')
    expect(person.user.lead_organizer?(prop)).to be_truthy
  end

  let(:proposal_type) { create(:proposal_type) }
  let(:proposal) { create(:proposal, proposal_type: proposal_type) }

  describe "GET /new" do
    before { get new_submit_proposal_path }
    it { expect(response).to have_http_status(:ok) }
  end

  describe "POST /create without invite" do
    let(:proposal) { create(:proposal) }
    let(:subject_category) { create(:subject_category) }
    let(:subject) { create(:subject, subject_category_id: subject_category.id) }
    let(:ams_subjects) do
      create_list(:ams_subject, 2, subject_category_ids: subject_category.id,
                                   subject_id: subject.id)
    end
    let(:location) { create(:location) }
    let(:invites_attributes) do
      {
        '0' => { firstname: 'First', lastname: 'Organizer',
                 deadline_date: DateTime.now, invited_as: 'Organizer' }
      }
    end

    let(:person) { create(:person) }
    let(:role) { create(:role, name: 'Staff') }
    let(:user) { create(:user, person: person) }
    let(:role_privilege) do
      create(:role_privilege,
             permission_type: "Manage", privilege_name: "SubmitProposalsController", role_id: role.id)
    end

    let(:params) do
      { proposal: proposal.id, title: 'Test proposal', year: '2023',
        subject_id: subject.id,
        ams_subjects: { code1: ams_subjects.first.id,
                        code2: ams_subjects.last.id },
        invites_attributes: invites_attributes,
        location_ids: location.id, no_latex: false }
    end

    before do
      role_privilege
      user.roles << role
      sign_in user
      post submit_proposals_url, params: params, xhr: true
    end

    it "updates the proposal but will not create invite" do
      expect(proposal.invites.count).to eq(0)
    end
  end

  describe "POST /create with invite parameters" do
    let(:proposal) { create(:proposal) }
    let(:subject_category) { create(:subject_category) }
    let(:subject) { create(:subject, subject_category_id: subject_category.id) }
    let(:ams_subject_code1) do
      create(:ams_subject, subject_category_ids:
                           subject_category.id, subject_id: subject.id)
    end
    let(:ams_subject_code2) do
      create(:ams_subject, subject_category_ids:
                           subject_category.id, subject_id: subject.id)
    end
    let(:location) { create(:location) }
    let(:invites_attributes) do
      { '0' => { firstname: 'First', lastname: 'Organizer',
                 email: 'organizer@gmail.com', deadline_date: DateTime.now,
                 invited_as: 'Organizer' } }
    end
    let(:params) do
      { proposal: proposal.id, title: 'Test proposal', year: '2023',
        subject_id: subject.id, ams_subjects: { code1: ams_subject_code1.id, code2: ams_subject_code2.id },
        invites_attributes: invites_attributes,
        location_ids: location.id, no_latex: false, create_invite: true }
    end

    context 'with valid invite params, as lead organizer' do
      let!(:proposal) { build :proposal, proposal_type: proposal_type, is_submission: true}
      before do
        @prop = @person.proposals.first
        expect(@person.user.lead_organizer?(@prop)).to be_truthy
        @invites_count = @prop.invites.count
        @submission = SubmitProposalService.new(proposal,params)
        @submission.params[:commit] = true
        post submit_proposals_url, params: params.merge(proposal: @prop.id), xhr: true
      end

      it { expect(response).to have_http_status(:ok) }

      it "updates the proposal invites count" do
        expect(@prop.invites.count).to eq(@invites_count + 1)
      end
    end

    context 'with valid invite params, as lead organizer and false create_invite' do
      before do
        params[:create_invite] = false
        @prop = @person.proposals.first
        expect(@person.user.lead_organizer?(@prop)).to be_truthy
        @invites_count = @prop.invites.count
        post submit_proposals_url, params: params.merge(proposal: @prop.id), xhr: true
      end

      it { expect(response).to have_http_status(:ok) }

      it "updates the proposal invites count" do
        expect(@prop.invites.count).to eq(@invites_count + 1)
      end
    end

    context 'with valid invite params, as lead organizer and nil create_invite' do
      before do
        params[:create_invite] = nil
        @prop = @person.proposals.first
        expect(@person.user.lead_organizer?(@prop)).to be_truthy
        @invites_count = @prop.invites.count
        post submit_proposals_url, params: params.merge(proposal: @prop.id), xhr: true
      end

      it { expect(response).to have_http_status(302) }
    end

    context 'with valid invite params, not as lead organizer' do
      before do
        expect(proposal.invites.count).to eq(0)
        post submit_proposals_url, params: params, xhr: true
      end

      it { expect(response).to have_http_status(:forbidden) }

      it "does not update the proposal invites count" do
        expect(proposal.invites.count).to eq(0)
      end
    end 

    context 'with invalid invite params, as lead organizer' do
      before do
        @prop = @person.proposals.first
        @invites_count = @prop.invites.count

        post submit_proposals_url, params: params.merge(proposal: @prop.id), xhr: false
      end

      it { expect(response).to have_http_status(302) }

      it "does not update the proposal invites count" do
        expect(proposal.invites.count).not_to eq(@invites_count + 1)
      end
    end

    context 'with invalid invite params, not as lead organizer' do
      before do
        proposal.invites.new(invites_attributes['0']).save
        expect(proposal.invites.count).to eq(1)

        post submit_proposals_url, params: params, xhr: true
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
