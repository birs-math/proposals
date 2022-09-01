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
    end
    it 'returns person who is lead_organizer in proposal' do
      expect(proposal.lead_organizer).to eq(proposal.people.last)
    end
  end

  describe '#subjects' do
    context 'When subject is not present' do
      let(:proposal) { build :proposal, is_submission: true, subject: nil }

      # it 'please select a subject area' do
      #   proposal.save
      #   expect(proposal.errors.full_messages).to include('Subject area: please select a subject area')
      # end
    end

    context 'When ams_subject code count is less than 2' do
      let(:proposal) { build :proposal, is_submission: true }
      let!(:proposal_ams_subject) { create :proposal_ams_subject, proposal: proposal }

      # it 'please select 2 AMS Subjects' do
      #   proposal.save
      #   expect(proposal.errors.full_messages).to include('Ams subjects: please select 2 AMS Subjects')
      # end
    end
  end

  describe 'impossible_dates' do
    context "when proposal is present" do
      let!(:proposal) { create(:proposal, assigned_date: "2023-01-15 - 2023-01-20") }
      let!(:proposal_field) { create(:proposal_field, :preferred_impossible_dates_field) }
      let!(:schedule_run) { create(:schedule_run) }
      let!(:schedule) { create(:schedule, schedule_run_id: schedule_run.id) }
      let!(:answers) do
        create(:answer, proposal: proposal, proposal_field: proposal_field,
                        answer: "[\"01/15/23 to 01/20/2023\",\"01/15/23 to 01/20/2023\",\"01/15/23 to 01/20/2023\",\"01/15/23 to 01/20/2023\",\"01/15/23 to 01/20/2023\",\"01/15/23 to 01/20/2023\"]")
      end

      it 'returns empty string when proposal preferred_dates are empty' do
        expect(proposal.impossible_dates).to be_a Array
      end
    end

    context "when proposal fields are blank" do
      let!(:proposal) { create(:proposal, assigned_date: "2023-01-15 - 2023-01-20") }
      let!(:proposal_field) { create(:proposal_field, nil) }
      let!(:schedule_run) { create(:schedule_run) }
      let!(:schedule) { create(:schedule, schedule_run_id: schedule_run.id) }
      let!(:answers) do
        create(:answer, proposal: proposal, proposal_field: proposal_field,
                        answer: "[\"01/15/23 to 01/20/2023\",\"01/15/23 to 01/20/2023\",\"01/15/23 to 01/20/2023\",\"01/15/23 to 01/20/2023\",\"01/15/23 to 01/20/2023\",\"01/15/23 to 01/20/2023\"]")
      end

      it 'returns empty string when proposal preferred_dates are empty' do
        expect(proposal.impossible_dates).to be_a Array
      end
    end

    describe 'max_supporting_organizers' do
      let!(:proposal) { create(:proposal) }
      it 'proposal type not present' do
        expect(proposal.max_supporting_organizers).to eq(3)
      end

      context 'proposal type present present' do
        let(:location) { create(:location) }
        let(:proposal_type) { create(:proposal_type, locations: [location]) }

        it 'proposal type present' do
          expect(proposal.max_supporting_organizers).to eq(3)
        end
      end
    end
  end
end
