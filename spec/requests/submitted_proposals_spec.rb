require 'rails_helper'

RSpec.describe "/submitted_proposals", type: :request do
  let(:proposal_type) { create(:proposal_type) }
  let(:proposal) { create(:proposal, :with_organizers, proposal_type: proposal_type, status: :decision_pending) }
  let(:person) { create(:person) }
  let(:location) { create(:location) }
  let(:role) { create(:role, name: 'Staff') }
  let(:staff_discussion) { create(:staff_discussion, proposal_id: proposal.id) }
  let(:user) { create(:user, person: person) }
  let(:role_privilege) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "StaffDiscussion", role_id: role.id)
  end
  let(:role_privilege_controller) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "SubmittedProposalsController", role_id: role.id)
  end
  let(:role_privilege_reviews) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "Review", role_id: role.id)
  end
  let(:role_privilege_email) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "Email", role_id: role.id)
  end

  before do
    role_privilege_reviews
    role_privilege_controller
    role_privilege_email
    user.roles << role
    sign_in user
  end

  describe "GET /index" do
    before do
      get submitted_proposals_url
    end

    it { expect(response).to have_http_status(:ok) }
  end

  describe "GET /download_csv" do
    it 'when proposal is selected' do
      proposal_ids = [proposal.id]

      get download_csv_submitted_proposals_path(ids: [proposal_ids])

      expect(response.header['Content-Type']).to eq("text/csv")
      expect(response).to have_http_status(:ok)
    end

    it 'no proposal is selected' do
      get download_csv_submitted_proposals_path(ids: [])

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /send_to_workshop" do
    let(:request) { post send_to_workshop_submitted_proposals_path(ids: [proposal.id]) }

    it 'posts to workshops API' do
      expect { request }.to have_enqueued_job(ExportProposalsJob)
    end
  end

  describe "GET /show" do
    let(:proposal_roles) { create_list(:proposal_role, 3, proposal: proposal) }
    before do
      proposal_roles.last.role.update(name: 'lead_organizer')
      get submitted_proposal_path(proposal)
    end

    context 'when proposal status is submitted' do
      before do
        proposal.update(status: "submitted")
        get submitted_proposal_path(proposal)
      end

      it 'update proposal status' do
        expect(proposal.reload.status).to eq("initial_review")
      end
    end

    it { expect(response).to have_http_status(:ok) }
  end

  describe "GET /edit" do
    before { get edit_submitted_proposal_path(proposal) }

    it { expect(response).to have_http_status(:ok) }
  end

  describe "POST /edit_flow when ids are in params" do
    let(:subject) { create(:subject) }
    let!(:ams_subject) { create(:ams_subject, subject: subject) }
    let(:params) do
      { ids: proposal.id }
    end

    it 'when status is unprocessable_entity' do
      post edit_flow_submitted_proposals_url, params: params
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "POST /edit_flow when ids are in params" do
    let(:proposal) { create(:proposal, :with_organizers, status: 'initial_review') }
    let(:params) { { ids: proposal.id } }

    before do
      stub_request(:post, "#{ENV['EDITFLOW_API_URL']}").to_return(body: { data: {} }.to_json)
    end

    context 'when AMS subject' do
      let(:ams_subject) { create(:ams_subject, subject: proposal.subject) }
      let(:proposal_ams_subject) { create(:proposal_ams_subject, proposal: proposal, ams_subject: ams_subject) }

      context 'present' do
        before do
          proposal_ams_subject

          post edit_flow_submitted_proposals_url, params: params
        end

        it('posts to editflow') { expect(WebMock).to have_requested(:post, ENV['EDITFLOW_API_URL']) }
      end

      context 'not present' do
        before do
          proposal_ams_subject
        end

        it('does not post to editflow') { expect(WebMock).not_to have_requested(:post, ENV['EDITFLOW_API_URL']) }
      end
    end
  end

  describe "POST /edit_flow when ids are not in params" do
    it 'when status is unprocessable_entity' do
      post edit_flow_submitted_proposals_url

      expect(response).to have_http_status(302)
    end
  end

  describe "POST /staff_discussion" do
    let(:params) { { discussion: "Testing.." } }
    context 'when valid params' do
      before do
        post staff_discussion_submitted_proposal_path(proposal, params: params)
      end

      it "add/creates staff discussion" do
        expect(response).to redirect_to(submitted_proposal_path(proposal))
      end
    end

    context 'when invalid params' do
      before do
        post staff_discussion_submitted_proposal_path(proposal, params: { discussion: nil })
      end

      it "discussion is not created" do
        expect(flash[:alert]).to eq(["Discussion can't be blank"])
      end
    end
  end


  describe "POST /send_emails with wrong params" do
    let(:email_template) { create(:email_template, email_type: :revision_type) }
    let(:params) do
      { cc_email: '',
        bcc_email: '',
        subject: email_template.subject,
        body: email_template.body,
        templates: "Test: Test Proposal"}
    end

    it "send emails to lead_organizer" do
      post send_emails_submitted_proposal_path(proposal, params: params)
      expect(response).to redirect_to(edit_submitted_proposal_path(proposal))
    end
  end

  describe "POST /send_emails with params Revision" do
    let!(:proposal) { create(:proposal, status: 'draft') }
    let(:email_template) { create(:email_template, email_type: :revision_type) }
    let(:params) do
      { cc_email: '',
        bcc_email: '',
        subject: email_template.subject,
        body: email_template.body,
        templates: "Revision: Revision Proposal",
        action: 'show' }
    end

    before do
    end

    it "send emails to lead_organizer" do
      @check_status = proposal.editable?
      post send_emails_submitted_proposal_path(proposal, params: params)
      expect(response).to redirect_to(edit_submitted_proposal_path(proposal))
    end
  end

  describe "POST /send_emails with params Revision" do
    let(:email_template) { create(:email_template, email_type: :revision_type) }
    let(:params) do
      { cc_email: '',
        bcc_email: '',
        subject: email_template.subject,
        body: email_template.body,
        templates: "Revision: Revision Proposal" }
    end

    it "send emails to lead_organizer" do
      post send_emails_submitted_proposal_path(proposal, params: params)
      expect(response).to redirect_to(edit_submitted_proposal_path(proposal))
    end
  end

  describe "POST /send_emails with params Approve" do
    let(:email_template) { create(:email_template, email_type: :revision_type) }
    let(:params) do
      { cc_email: '',
        bcc_email: '',
        subject: email_template.subject,
        body: email_template.body,
        templates: "Revision SPC: Revision SPC Proposal" }
    end

    it "send emails to lead_organizer" do
      post send_emails_submitted_proposal_path(proposal, params: params)
      expect(response).to redirect_to(edit_submitted_proposal_path(proposal))
    end
  end

  describe "POST /send_emails with params Reject" do
    let!(:email_template) { create(:email_template, email_type: :revision_type) }

    let(:params) do
      { cc_email: [{ value: "john@gmail.com" }, { value: "hgvs@gmail.com" }].to_json,
        bcc_email: Faker::Internet.email(domain: 'gmail.com'),
        subject: email_template.subject,
        body: email_template.body,
        templates: "Reject: Reject Proposal",
        action: 'show' }
    end

    it "send emails to lead_organizer" do
      post send_emails_submitted_proposal_path(proposal, params: params)
      expect(response).to redirect_to(edit_submitted_proposal_path(proposal))
    end
  end

  describe "POST /send_emails with params Decision" do
    let(:email_template) { create(:email_template, email_type: :revision_type) }
    let(:params) do
      { cc_email: [{ value: "john@gmail.com" }, { value: "hgvs@gmail.com" }].to_json,
        bcc_email: Faker::Internet.email(domain: 'gmail.com'),
        subject: email_template.subject,
        body: email_template.body,
        templates: "Decision Decision Proposal" }
    end

    it "send emails to lead_organizer" do
      post send_emails_submitted_proposal_path(proposal, params: params)
      expect(response).to redirect_to(edit_submitted_proposal_path(proposal))
    end
  end

  describe 'POST /submitted_proposals/approve_decline_proposals' do
    let(:email_template) { create(:email_template, email_type: :approval_type) }
    let(:params) do
      { cc_email: [{ value: "john@gmail.com" }, { value: "hgvs@gmail.com" }].to_json,
        bcc_email: Faker::Internet.email(domain: 'gmail.com'),
        subject: email_template.subject,
        templates: "Approval: Approve proposal",
        body: email_template.body,
        proposal_ids: proposal.id }
    end

    context 'when proposal can be approved/rejected' do
      before do

        post approve_decline_proposals_submitted_proposals_path(params: params)
      end

      it 'updates proposals status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when proposal can not be approved/rejected' do
      before do
        proposal.update(status: :submitted)
        post approve_decline_proposals_submitted_proposals_path(params: params)
      end

      it 'not update proposal status' do
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'POST /submitted_proposals/:id/update_status' do
    before { post update_status_submitted_proposal_path(id: proposal.id, status: Proposal.statuses[:in_progress]) }

    context 'when status is blank' do
      before { post update_status_submitted_proposal_path(id: proposal.id, status: '') }

      it 'does not update proposal status' do
        expect(response).to have_http_status(200)
      end
    end

    it 'update proposal status' do
      expect(proposal.reload.status).to eq("in_progress")
    end
  end

  describe 'POST /submitted_proposals/:id/update_location' do
    # before { post update_location_submitted_proposal_path(id: proposal.id, location: location) }

    context 'for valid parameters' do
      before { post update_location_submitted_proposal_path(id: proposal.id, location: location) }
      it 'update proposal location' do
        expect(response).to have_http_status(200)
      end
    end
    context 'for invalid parameters' do
      before { post update_location_submitted_proposal_path(id: proposal.id) }
    end
  end

  describe 'POST /submitted_proposals/table_of_content' do
    let(:params) do
      { proposal_ids: proposal.id }
    end
    before do
      post table_of_content_submitted_proposals_path(params: params)
    end

    it 'will return proposals' do
      expect(response).to have_http_status(200)
    end
  end

  describe "DELETE /destroy" do
    before do
      delete submitted_proposal_url(proposal)
    end
    it { expect(Proposal.all.count).to eq(0) }
  end

  describe "POST /proposals_booklet" do
    let(:params) do
      {
        proposal_ids: proposal.id,
        table: "toc"
      }
    end

    before do
      post proposals_booklet_submitted_proposals_path(params: params)
    end

    it "render a successful response" do
      expect(response).to have_http_status(202)
    end
  end

  describe "POST /import_reviews" do
    let(:params) do
      { proposals: proposal.id }
    end

    before do
      post import_reviews_submitted_proposals_path(params: params)
    end

    it "render a successful response" do
      expect(response).to have_http_status(202)
    end
  end

  describe "POST /reviews_booklet" do
    let(:params) do
      {
        proposals: proposal.id,
        reviewContentType: "both",
        table: "toc"
      }
    end

    before do
      post reviews_booklet_submitted_proposals_path(params: params)
    end

    it "render a successful response" do
      expect(response).to have_http_status(202)
    end
  end

  describe 'POST /submitted_proposals/proposal_outcome_location' do
    let(:location) { create(:location) }
    let(:params) do
      { proposal:
        {
          id: proposal.id,
          outcome: 'Approved',
          assigned_location_id: location.id,
          assigned_size: "Half"
        } }
    end

    before do
      post proposal_outcome_location_submitted_proposals_path(params: params)
    end

    it 'will update selected proposals' do
      expect(response).to have_http_status(200)
    end
  end

  describe ' POST /submitted_proposals/revise_proposal_editflow' do
    context 'post to editflow' do
      before do
        proposal.update(editflow_id: 122)
        stub_request(:post, "#{ENV['EDITFLOW_API_URL']}").to_return(body: { data: {} }.to_json)

        post revise_proposal_editflow_submitted_proposals_url(proposal_id: proposal.id)
      end

      it { expect(WebMock).to have_requested(:post, "#{ENV['EDITFLOW_API_URL']}") }

      it 'revise proposal editflow when not progress spc' do
        expect(response).to have_http_status(302)
      end
    end

    it 'revise proposal editflow when progress spc and editflow id is blank' do
      proposal.update(status: "revision_submitted_spc")

      post revise_proposal_editflow_submitted_proposals_url(proposal_id: proposal.id)

      expect(response).to have_http_status(302)
    end
  end

  describe 'GET/ download_review_booklet_submitted_proposals' do
    it 'when file is not present' do
      get download_review_booklet_submitted_proposals_path
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET/ reviews_excel_booklet_submitted_proposals' do
    let!(:proposal) { create(:proposal) }
    let(:subject) { create(:subject) }
    let!(:review) { create(:review, person_id: person.id) }
    it 'when file is not present' do
      params = { proposals: proposal.id,
                 format: :xlsx }
      proposal.update(subject_id: subject.id)
      get reviews_excel_booklet_submitted_proposals_path, params: params
      expect(response).to have_http_status(200)
    end

    it 'when reviews are present for proposal' do
      params = { proposals: proposal.id,
                 format: :xlsx }
      proposal.update(subject_id: subject.id)
      review.update(proposal_id: proposal.id)
      get reviews_excel_booklet_submitted_proposals_path, params: params
      expect(response).to have_http_status(200)
    end

    # it 'when editflow_id is present for proposal' do
    #   params = { proposals: proposal.id,
    #             format: :xlsx }
    #   EDITFLOW_API_URL = 'test/editflow/api/id'
    #   EDITFLOW_API_TOKEN = 'test/editflow/api/token'
    #   proposal.update(subject_id: subject.id, editflow_id: Time.now)
    #   get reviews_excel_booklet_submitted_proposals_path(), params: params
    #   expect(response).to have_http_status(200)
    # end
  end

  describe 'GET/ reviews_excel_booklet_submitted_proposals' do
    let(:subject) { create(:subject) }
    let!(:review) { create(:review, person_id: person.id) }

    before do
    end

    it 'when proposal ids not present for reviews' do
      params = { proposals: nil,
                 format: :xlsx }
      proposal.update(subject_id: subject.id)
      review.update(proposal_id: proposal.id)
      get reviews_excel_booklet_submitted_proposals_path, params: params
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET/ reviews_excel_booklet_submitted_proposals' do
    let!(:proposal) { create(:proposal) }
    let(:subject) { create(:subject) }
    let!(:review) { create(:review, person_id: person.id) }

    before do
    end

    it 'when proposal ids present for reviews' do
      params = { proposals: proposal.id,
                 format: :xlsx }
      proposal.update(subject_id: subject.id)
      review.update(proposal_id: proposal.id)
      get reviews_excel_booklet_submitted_proposals_path, params: params
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /reviews_excel_booklet_submitted_proposals' do
    let!(:proposal) { create(:proposal, editflow_id: 1222) }
    let(:subject) { create(:subject) }

    before do
      stub_request(:post, "#{ENV['EDITFLOW_API_URL']}").to_return(body: { data: {} }.to_json)
    end

    it 'when proposal ids present for reviews' do
      params = { proposals: proposal.id,
                 format: :xlsx }

      proposal.update(subject_id: subject.id)

      get reviews_excel_booklet_submitted_proposals_path, params: params

      expect(WebMock).to have_requested(:post, ENV['EDITFLOW_API_URL'])
    end
  end
end
