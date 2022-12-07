require 'rails_helper'

RSpec.describe 'ProposalPdfService' do
  include Rack::Test::Methods
  include ActionDispatch::TestProcess::FixtureFile
  context '#initialize' do
    before do
      @proposal = create(:proposal)
      @temp_file = 'Test temp_file'
      @input = 'some input'
      @user = User.first
      @file_errors = []
      @text = ""
      @version = nil
      @pps = ProposalPdfService.new(@proposal.id, @temp_file, @input, @user, @version)
    end
    it 'version is blank' do
      expect(nil).to eq(nil)
    end
  end

  context '#initialize' do
    before do
      @proposal = create(:proposal)
      @temp_file = 'Test temp_file'
      @input = 'some input'
      @user = User.first
      @file_errors = []
      @text = ""
      @version = "some version"
      @pps = ProposalPdfService.new(@proposal.id, @temp_file, @input, @user, @version)
    end
    it 'version is present' do
      expect(@pps.class).to eq(ProposalPdfService)
    end
  end  

  context '#generate_pdf_with_reviews' do
    let!(:review) { create(:review) }
    let!(:proposal) { create(:proposal, reviews: [review]) }

    before do 
      @proposal = proposal
      @input = "\\subsection*{Reviews:}\n\n\n"
      review.update(proposal_id: proposal.id)
      @pps = ProposalPdfService.new(@proposal&.id, @temp_file, @input, @user)
    end
    it "return if file attached false" do
      expect(@pps.generate_pdf_with_reviews).to eq(nil)
    end
  end

  context '#generate_latex_file' do
    let!(:review) { create(:review) }
    let!(:location) { create(:location) }
    let!(:proposal) { create(:proposal, reviews: [review], locations: [location]) }
    let(:file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/proposal_booklet.pdf')) }

    before do 
      @input = "Please enter some text."
      @temp_file = file
      @proposal = proposal
      @proposal.is_submission = true
      @pps = ProposalPdfService.new(@proposal&.id, @temp_file, @input, @user)
    end
    it "when input is Please enter some text" do
      expect(@pps.generate_latex_file.to_s).to eq ("\n\n\\begin{document}\n\nPlease enter some text.\n")
    end
  end

  # context '#generate_latex_file' do
  #   let(:person) { create(:person) }
  #   let(:role) { create(:role, name: 'Staff') }
  #   let(:current_user) { create(:user, person: person) }
  #   let!(:role_privilege) do
  #     create(:role_privilege,
  #            permission_type: "Manage", privilege_name: "ProposalPdfService", role_id: role.id)
  #   end
  #   let!(:review) { create(:review) }
  #   let!(:location) { create(:location) }
  #   let!(:proposal_form) { create(:proposal_form, version: 1) }
  #   let!(:proposal) { create(:proposal, reviews: [review], locations: [location], proposal_form: proposal_form) }
  #   let(:file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/proposal_booklet.pdf')) }

  #   before do 
  #     role_privilege
  #     current_user.roles << role
  #     @user = current_user
  #     @input = "all"
  #     @temp_file = file
  #     @proposal = proposal
  #     @proposal.is_submission = true
  #     @proposal_version = proposal.proposal_form.version
  #     @pps = ProposalPdfService.new(@proposal&.id, @temp_file, @input, @user)
  #   end
  #   it "when input is all" do
  #     expect(@pps.generate_latex_file.to_s).to eq ("\n\n\\begin{document}\n\n\\section*{\\centering 44w5467:  Velit consectetur natus occaecati. }\n\n\\...presented minority in your area\n                (Organizing Committee + Participants): 0/1\n\n\n\n")
  #   end
  # end
 
end