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
end
