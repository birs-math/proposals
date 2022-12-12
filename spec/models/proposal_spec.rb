require 'rails_helper'

RSpec.describe Proposal, type: :model do
  describe 'validations' do
    it 'has valid factory' do
      expect(build(:proposal)).to be_valid
    end

    # need validation before final submit
    # it 'is invalid without year' do
    #   expect(build(:proposal, year: nil)).to be_invalid
    # end

    # it 'is invalid without title' do
    #   expect(build(:proposal, title: nil)).to be_invalid
    # end
  end

  # must only be executed upon final submission
  # describe 'proposal code creation' do
  #   it 'creates a new code if no code is given' do
  #     proposal = build(:proposal, code: nil)
  #     expect(proposal).to be_valid
  #     expect(proposal.code).not_to be_empty
  #   end

  #   it 'new codes end in sequential integers' do
  #     type = create(:proposal_type, name: '5 Day Workshop')
  #     create(:proposal, proposal_type: type, status: 1, code: '23w5005')
  #     proposal = build(:proposal, proposal_type: type, code: nil)

  #     expect(proposal).to be_valid
  #     expect(proposal.code).to eq('23w5006')
  #   end
  # end

  describe 'associations' do
    it { should have_many(:proposal_locations).dependent(:destroy) }
    it { should have_many(:locations).through(:proposal_locations) }
    it { should belong_to(:proposal_type) }
    it { should have_many(:proposal_roles).dependent(:destroy) }
    it { should have_many(:people).through(:proposal_roles) }
    it { should have_many(:reviews).dependent(:destroy) }
    it { should have_many(:proposal_versions).dependent(:destroy) }
  end

  describe '#lead_organizer' do
    let(:proposal) { create(:proposal) }
    let(:proposal_roles) { create_list(:proposal_role, 3, proposal: proposal) }
    before do
      proposal_roles.last.role.update(name: 'lead_organizer')
      proposal.lead_organizer
    end
    it 'returns person who is lead_organizer in proposal' do
      expect(proposal.lead_organizer).to eq(proposal.people.last)
    end
  end


  describe '#deographics_data' do
    context "Demographics data for participants" do
      let(:invite) { create(:invite, invited_as: 'Participant') }
      let!(:proposal) { create(:proposal) }

      before do
        proposal.demographics_data
      end

      it 'returns demographicData for Participant' do
        expect(proposal.demographics_data).to eq([])
      end
    end
  end  


  describe '#the_locations' do
    context "the locations" do
      let(:location) { create(:location) } 
      let!(:proposal) { create(:proposal) }

      before do
        proposal.the_locations
      end

      it 'returns location' do
        expect(proposal.the_locations).to eq("")
      end
    end
  end 

  describe '#supporting organizer fullnames' do
    context "supporting organizer fullnames" do
      let!(:proposal) { create(:proposal) }

      before do
        Proposal.supporting_organizer_fullnames(proposal)
      end

      it 'returns supporting organizers fullnames' do
        expect(Proposal.supporting_organizer_fullnames(proposal)).to eq("#{proposal&.supporting_organizers&.first&.firstname}#{proposal&.supporting_organizers&.first&.lastname}" )
      end
    end
  end 

  describe '#supporting organizer emails' do
    context "supporting organizer email" do
      let!(:proposal) { create(:proposal) }

      before do
        Proposal.supporting_organizer_emails(proposal)
      end

      it 'returns supporting organizers emails' do
        expect(Proposal.supporting_organizer_emails(proposal)).to eq("#{proposal&.supporting_organizers&.first&.email}" )
      end
    end
  end  

  describe '#participants fullnames' do
    context "participants fullnames" do
      let!(:proposal) { create(:proposal) }

      before do
        Proposal.participants_fullnames(proposal)
      end

      it 'returns participants fullnames' do
        expect(Proposal.participants_fullnames(proposal)).to eq("#{proposal&.participants&.first&.firstname}#{proposal&.participants&.first&.lastname}" )
      end
    end
  end 

  describe '#participants emails' do
    context "participants emails" do
      let!(:proposal) { create(:proposal) }

      before do
        Proposal.participants_emails(proposal)
      end

      it 'returns participants emails' do
        expect(Proposal.participants_emails(proposal)).to eq("#{proposal&.participants&.first&.email}" )
      end
    end
  end  

  describe '#list of organizers' do
    context "list of organizerss" do
      let(:invite) { create(:invite, invited_as: 'Organizer', status: 'confirmed') }
      let!(:proposal) { create(:proposal) }

      before do
        proposal.list_of_organizers
      end

      it 'returns list of orgainzers' do
        expect(proposal.list_of_organizers).to eq("")
      end
    end
  end  


  describe '#supporting organizer' do
    context "supporting organizers" do
      let(:invite) { create(:invite, invited_as: 'Organizer', response: %w[yes maybe]) }
      let!(:proposal) { create(:proposal) }

      before do
        proposal.supporting_organizers
      end

      it 'returns supporting organizers' do
        expect(proposal.supporting_organizers).to eq([])
      end
    end
  end 


  describe '#participants' do
    context "participants" do
      let(:invite) { create(:invite, invited_as: 'Participants', response: %w[yes maybe]) }
      let!(:proposal) { create(:proposal) }

      before do
        proposal.participants
      end

      it 'returns supporting organizers' do
        expect(proposal.participants).to eq([])
      end
    end
  end 

  describe '#get confirmed participants' do
    context "get Confirmed participants" do
      let(:invite) { create(:invite, status: 1, invited_as: 'Participants') }
      let!(:proposal) { create(:proposal) }

      before do
        proposal.get_confirmed_participant(proposal)
      end

      it 'returns confirm participants' do
        expect(proposal.get_confirmed_participant(proposal)).to eq([])
      end
    end
  end   

  describe '#invites_demographic_data' do
    context "Invites Demographic data " do
      let(:invite) { create(:invite, status: 'confirmed') }
      let!(:proposal) { create(:proposal) }

      before do
        proposal.invites_demographic_data
      end

      it 'returns demographicData' do
        expect(proposal.invites_demographic_data).to eq([])
      end
    end
  end

  describe '#birs email' do
    context "birs email" do
      emails = ['birs-director@birs.ca','birs@birs.ca']
      let!(:proposal) { create(:proposal) }

      before do
        proposal.birs_emails
      end
      
      it 'birs email' do
        expect(proposal.birs_emails).to eq(emails)
      end
    end
  end

  describe '#max supporting organizers' do
    context "max supporting organizers" do
      let (:proposal_type) { create(:proposal_type, co_organizer: 3) }
      let!(:proposal) { create(:proposal) }

      before do
        proposal.max_supporting_organizers
      end
      
      it 'max supporting organizers' do
        expect(proposal.max_supporting_organizers).to eq(3)
      end
    end
  end

  describe '#max participants' do
    context "max participants" do
      let (:proposal_type) { create(:proposal_type, participant: 2) }
      let!(:proposal) { create(:proposal) }

      before do
        proposal.max_participants
      end
      
      it 'max participants' do
        expect(proposal.max_participants).to eq(proposal_type.participant)
      end
    end
  end

  describe '#max virtual participants' do
    context "max virtual participants" do
      let!(:proposal) { create(:proposal) }

      before do
        proposal.max_virtual_participants
      end
      
      it 'max virtual participants' do
        expect(proposal.max_virtual_participants).to eq(300)
      end
    end
  end

  describe '#max total participants' do
    context "max total participants" do
      let!(:proposal) { create(:proposal) }

      before do
        proposal.max_total_participants
      end
      
      it 'max virtual total participants' do
        expect(proposal.max_total_participants).to eq(302)
      end
    end
  end

  describe '#macros' do
    context "macros" do
      let!(:proposal) { create(:proposal) }

      before do
        proposal.macros
      end
      
      it 'macros' do
        expect(proposal.macros).to eq('')
      end
    end
  end

  describe '#pdf_file_type' do
    include Rack::Test::Methods
    include ActionDispatch::TestProcess::FixtureFile
    context "pdf_file_type" do
      let!(:proposal) { create(:proposal) }
      let(:file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/proposal_booklet.pdf')) }

      before do
        proposal.pdf_file_type(file)
      end
      
      it 'pdf_file_type' do
        expect(proposal.pdf_file_type(file)).to be_falsey
      end
    end
  end

  describe '#subjects' do
    context 'When subject is not present' do
      let(:proposal) { build :proposal, is_submission: true, subject: nil }

      it 'please select a subject area' do
        proposal.save
        expect(proposal.errors.full_messages).to include('Subject area: please select a subject area')
      end
    end

    context 'When ams_subject code count is less than 2' do
      let(:proposal) { build :proposal, is_submission: true }
      let!(:proposal_ams_subject) { create :proposal_ams_subject, proposal: proposal }

      it 'please select 2 AMS Subjects' do
        proposal.save
        expect(proposal.errors.full_messages).to include('Ams subjects: please select 2 AMS Subjects')
      end
    end
  end

  describe '#preferred_dates' do
    context 'When answer is not present' do
      let!(:proposal) { create(:proposal) }
      let(:answer) { create(:answer) }

      before do
        answer = nil
      end
      it 'return '' when answer is blank' do
        expect(proposal.preferred_dates).to include('')
      end
    end
  end

  describe '#preferred_dates' do
    context 'When answer is present' do
      let(:proposal) { create(:proposal, assigned_date: "2023-01-15 - 2023-01-20") }
      let!(:proposal_field) { create(:proposal_field) }
      let(:schedule_run) { create(:schedule_run) }
      let(:schedule) { create(:schedule, schedule_run_id: schedule_run.id) }
      let!(:answers) { create(:answer, proposal: proposal, proposal_field: proposal_field) }

      before do
        proposal_field.update_columns(fieldable_type: "ProposalFields::PreferredImpossibleDate")
        proposal_field.answer.update_columns(answer: "[\" 01/19/24 to 01/23/24\", \"04/11/24 to 04/15/24\", \"07/11/24 to 7/15/24\", \"08/11/24 to 08/15/24\", \"\", \"12/11/24 to 12/15/24\", \" 02/19/24 to 02/23/24\"]")
      end
      it 'return preferred_dates' do
        expect(proposal.preferred_dates).to be_a Array
      end
    end
  end

  describe '#impossible_dates' do
    context 'When answer is not present' do
      let!(:proposal) { create(:proposal) }
      let(:answer) { create(:answer) }

      before do
        answer = nil
      end
      it 'return '' when answer is blank' do
        expect(proposal.impossible_dates).to eq []
      end
    end
  end

  describe '#impossible_dates' do
    context 'When answer is present' do
      let(:proposal) { create(:proposal, assigned_date: "2023-01-15 - 2023-01-20") }
      let!(:proposal_field) { create(:proposal_field) }
      let(:schedule_run) { create(:schedule_run) }
      let(:schedule) { create(:schedule, schedule_run_id: schedule_run.id) }
      let!(:answers) { create(:answer, proposal: proposal, proposal_field: proposal_field) }

      before do
        proposal_field.update_columns(fieldable_type: "ProposalFields::PreferredImpossibleDate")
        proposal_field.answer.update_columns(answer: "[\" 01/19/24 to 01/23/24\", \"04/11/24 to 04/15/24\", \"07/11/24 to 7/15/24\", \"08/11/24 to 08/15/24\", \"\", \"12/11/24 to 12/15/24\", \" 02/19/24 to 02/23/24\"]")
      end
      it 'return impossible dates' do
        expect(proposal.impossible_dates).to be_a Array
      end
    end
  end
end
