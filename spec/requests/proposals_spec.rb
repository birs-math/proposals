require 'rails_helper'

RSpec.describe "Proposals", type: :request do
  let(:user) { create(:user) }
  let!(:person) { create(:person, :with_proposals, user: user) }
  let(:proposal) { person.proposals.first }

  before { authenticate_for_controllers(person) }

  describe "GET /index" do
    before do
      person
      get proposals_path
    end
    it { expect(response).to have_http_status(:ok) }
  end

  describe "PATCH /ranking" do
    let(:proposal) { create(:proposal) }
    let(:location) { create(:location) }
    let(:proposal_location) { create(:proposal_location, proposal_id: proposal.id, location_id: location.id) }
    before do
      proposal_location
      patch ranking_proposal_path(proposal, location_id: location.id, position: 2)
    end
    it { expect(response).to have_http_status(:ok) }
  end

  describe "GET /new" do
    before { get new_proposal_path }
    it { expect(response).to have_http_status(:ok) }
  end

  describe "POST /create" do
    let(:proposal_form) { create(:proposal_form, proposal_type: proposal.proposal_type, status: 'active') }
    before do
      proposal_form
      post proposals_path, params: params
    end

    context 'when does not have proposal it will create new' do
      let(:proposal_type) { create(:proposal_type) }
      let(:form) { create(:proposal_form, status: :active, proposal_type: proposal_type) }
      let(:params) do
        { proposal: { proposal_type_id: form.proposal_type.id, title: 'Test proposal', year: '2025' } }
      end

      it { expect(response).to redirect_to(edit_proposal_path(Proposal.last)) }
    end
  end

  describe "POST /upload_file" do
    it 'accepts a file upload'
  end

  describe "GET /show" do
    before { get proposal_path(proposal) }

    it { expect(response).to have_http_status(:ok) }
  end

  describe "GET /edit" do
    before { get edit_proposal_path(proposal) }

    it { expect(response).to have_http_status(:ok) }
  end

  describe "GET /locations" do
    before { get locations_proposal_path(proposal) }

    it { expect(response).to have_http_status(:ok) }
  end

  describe "print latex" do
    it 'latex input' do
      post "/proposals/#{proposal.id}/latex"
      expect(response).to have_http_status(:ok)
    end

    it 'latex output' do
      get rendered_proposal_proposal_url(proposal)
      expect(response).to have_http_status(:ok)
    end

    it 'latex field' do
      get rendered_field_proposal_url(proposal)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /destroy" do
    before do
      delete proposal_url(proposal)
    end

    it { expect(Proposal.all.count).to eq(2) }
  end

  describe "GET /versions" do
    before { get versions_proposal_path(proposal) }

    it { expect(response).to have_http_status(:ok) }
  end

  describe "GET /proposal_version" do
    before { get proposal_version_proposal_path(proposal) }

    it { expect(response).to have_http_status(:ok) }
  end

  describe "POST /upload_file" do
    include Rack::Test::Methods
    include ActionDispatch::TestProcess::FixtureFile
    context 'when file content type is plain text or pdf' do
      it 'saves the uploaded file' do
        file = []
        file << fixture_file_upload(Rails.root.join('spec/fixtures/files/proposal_booklet.pdf'),
                                    'application/pdf')
        expect do
          post upload_file_proposal_url(proposal), files: file
        end.to change(ActiveStorage::Attachment, :count).by(1)
      end
    end

    context 'when file content type is not plain text or pdf' do
      it 'saves the uploaded file' do
        file = []
        file << fixture_file_upload(Rails.root.join('spec/fixtures/files/review_sample.xlsx'))
        expect do
          post upload_file_proposal_url(proposal), files: file
        end.to change(ActiveStorage::Attachment, :count).by(0)
      end
    end
  end

  describe 'POST /remove_file' do
    include Rack::Test::Methods
    include ActionDispatch::TestProcess::FixtureFile
    let(:role) { create(:role, name: 'Staff') }
    let(:file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/proposal_booklet.pdf')) }
    before do
      proposal.files.attach(file)
    end

    it 'removes uploaded file' do
      expect do
        post remove_file_proposal_url(proposal), params: { attachment_id: proposal.files.first.id }
      end.to change(ActiveStorage::Attachment, :count).by(0)
    end
  end

  describe "GET /locations(" do
    it 'proposal location' do
      get locations_proposal_url(proposal)
      expect(response).to have_http_status(:ok)
    end
  end
end
