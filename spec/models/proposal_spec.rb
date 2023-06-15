require 'rails_helper'

RSpec.describe Proposal, type: :model do
  let(:proposal) { create(:proposal) }
  let(:invite) { create(:invite, status: status, response: response, invited_as: invited_as, proposal: proposal) }
  let(:invited_as) { 'Participant' }
  let(:status) { :confirmed }
  let(:response) { :yes }

  describe 'validations' do
    it 'has valid factory' do
      expect(build(:proposal)).to be_valid
    end

    context 'validations before final submit' do
      it 'is invalid without year' do
        expect(build(:proposal, year: nil, is_submission: true)).to be_invalid
      end

      it 'is invalid without title' do
        expect(build(:proposal, title: nil, is_submission: true)).to be_invalid
      end
    end
  end

  describe 'proposal code creation' do
    let(:proposal) { create(:proposal, :submission, code: nil, proposal_type: type, year: year) }
    let(:type) { create(:proposal_type, name: '5 Day Workshop', code: 'w5') }
    let(:year) { Date.current.year.to_i + 2 }
    let(:year_code) { year.to_s[-2..] }

    before { create(:proposal, proposal_type: type, status: :submitted, code: "#{year_code}w5005") }

    it 'creates a new code if no code is given' do
      expect(proposal.code).not_to be_empty
    end

    it 'sequences the code' do
      expect(proposal.code).to eq("#{year_code}w5006")
    end
  end

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
    let(:proposal_role) { proposal_roles.first }

    before do
      proposal_role.role.update(name: 'lead_organizer')
    end

    it 'returns lead organizer' do
      expect(proposal.lead_organizer).to eq(proposal_role.person)
    end
  end


  describe '#deographics_data' do
    let(:invite) { create(:invite, invited_as: 'Participant') }
    let!(:proposal) { create(:proposal) }

    before do
      proposal.demographics_data
    end

    it 'returns demographicData for Participant' do
      expect(proposal.demographics_data).to eq([])
    end
  end


  describe '#the_locations' do
    let(:location) { create(:location) }

    before do
      proposal.locations << location
    end

    it 'returns location' do
      expect(proposal.the_locations).to eq(location.name)
    end
  end

  describe '#supporting organizer fullnames' do
    it 'returns supporting organizers fullnames' do
      expect(described_class.supporting_organizer_fullnames(proposal))
        .to eq("#{proposal&.supporting_organizers&.first&.firstname}#{proposal&.supporting_organizers&.first&.lastname}" )
    end
  end

  describe '#supporting organizer emails' do
    it do
      expect(described_class.supporting_organizer_emails(proposal))
        .to eq("#{proposal&.supporting_organizers&.first&.email}" )
    end
  end

  describe '#participants_fullnames' do
    it do
      expect(described_class.participants_fullnames(proposal))
        .to eq("#{proposal&.participants&.first&.firstname}#{proposal&.participants&.first&.lastname}" )
    end
  end

  describe '#participants emails' do
    it 'returns participants emails' do
      expect(described_class.participants_emails(proposal)).to eq("#{proposal&.participants&.first&.email}" )
    end
  end

  describe '#list_of_organizers' do
    let(:invited_as) { 'Organizer' }

    before { invite }

    it 'returns list of orgainzers' do
      expect(proposal.list_of_organizers).to eq(invite.person.fullname)
    end
  end


  describe '#supporting_organizer' do
    let(:invited_as) { 'Organizer' }

    before { invite }

    it 'returns supporting organizers' do
      expect(proposal.supporting_organizers.to_a).to eq([invite])
    end
  end


  describe '#participants' do
    let(:invite) { create(:invite, invited_as: 'Participant', response: :yes, status: :confirmed, proposal: proposal) }
    let(:proposal) { create(:proposal) }

    it 'returns supporting xorganizers' do
      expect(proposal.participants).to eq([invite])
    end
  end

  describe '#get_confirmed_participants' do
    let(:invited_as) { 'Participant' }

    before { invite }

    it do
      expect(proposal.get_confirmed_participant(proposal)).to eq([invite.person])
    end
  end

  describe '#invites_demographic_data' do
    let(:invite) { create(:invite, status: 'confirmed') }

    it 'returns demographicData' do
      expect(proposal.invites_demographic_data).to eq([])
    end
  end

  describe '#birs_email' do
    it do
      expect(proposal.birs_emails).to eq(%w[birs-director@birs.ca birs@birs.ca])
    end
  end

  describe '#max_supporting_organizers' do
    let(:proposal_type) { create(:proposal_type, co_organizer: 3) }
    let(:proposal) { create(:proposal, proposal_type: proposal_type) }

    it { expect(proposal.max_supporting_organizers).to eq(3) }
  end

  describe '#max_participants' do
    let(:proposal_type) { create(:proposal_type, participant: 2) }
    let(:proposal) { create(:proposal, proposal_type: proposal_type) }

    it { expect(proposal.max_participants).to eq(proposal_type.participant) }
  end

  describe '#max virtual participants' do
    it { expect(proposal.max_virtual_participants).to eq(300) }
  end

  describe '#max total participants' do
    it { expect(proposal.max_total_participants).to eq(302) }
  end

  describe '#macros' do
    it { expect(proposal.macros).to eq('') }
  end

  describe '#pdf_file_type' do
    include Rack::Test::Methods
    include ActionDispatch::TestProcess::FixtureFile

    let(:file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/proposal_booklet.pdf')) }

    it 'pdf_file_type' do
      expect(proposal.pdf_file_type(file)).to be_falsey
    end
  end

  describe '#subjects' do
    before { proposal.save }

    context 'When subject is not present' do
      let(:proposal) { build :proposal, is_submission: true, subject: nil }

      it 'has error message' do
        expect(proposal.errors.full_messages).to include('Subject area: please select a subject area')
      end
    end

    context 'When ams_subject code count is less than 2' do
      let(:proposal) { build :proposal, is_submission: true }
      let!(:proposal_ams_subject) { create :proposal_ams_subject, proposal: proposal }

      it 'please select 2 AMS Subjects' do
        expect(proposal.errors.full_messages).to include('Ams subjects: please select 2 AMS Subjects')
      end
    end
  end

  describe '#preferred_dates' do
    context 'When answer is not present' do
      it 'return '' when answer is blank' do
        expect(proposal.preferred_dates).to eq('')
      end
    end

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
      it 'return [] when answer is blank' do
        expect(proposal.impossible_dates).to eq([])
      end
    end

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
