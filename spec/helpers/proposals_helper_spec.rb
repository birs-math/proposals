require 'rails_helper'

RSpec.describe ProposalsHelper, type: :helper do
  describe "#proposal_types" do
    let(:location) { create(:location) }
    let(:proposal_type) { create(:proposal_type, locations: [location]) }
    let(:published_form) { create(:proposal_form, proposal_type: proposal_type, status: :active) }
    let(:proposal_type1) { create(:proposal_type, locations: [location]) }
    let(:draft_form) { create(:proposal_form, proposal_type: proposal_type1, status: :draft) }

    it "returns proposal types [name,id] if it has publish form" do
      published_form
      expect(proposal_types).to eq([[proposal_type.name, proposal_type.id]])
    end

    it "returns no proposal types [name,id] if not has publish form" do
      draft_form
      expect(proposal_types).to eq([])
    end
  end

  describe "#proposal_type_year" do
    let(:proposal_type) { create(:proposal_type) }
    it "return array of year comma separated [year]" do
      expect(proposal_type_year(proposal_type)).to eq(%w[2021 2022 2023])
    end
    it "does not return array of year comma separated [year]" do
      proposal_type.update(year: "")
      expect(proposal_type_year(proposal_type)).to eq([Date.current.year + 2])
    end
  end

  describe "#locations" do
    let(:locations_list) { create_list(:location, 4) }
    it "returns array of locations [name,id]" do
      locations_list
      expect(locations).to match_array(locations_list.pluck(:name, :id))
    end
  end

  describe "#all_statuses" do
    it "returns array of statuses[status,id] " do
      expect(all_statuses).to eq(Proposal.statuses.map { |k, v| [k.humanize.capitalize, v] })
    end
  end

  describe "#all_proposal_types" do
    let(:proposal_types_list) { create_list(:proposal_type, 4) }
    it "returns array of proposal_types [name,id]" do
      proposal_types_list
      expect(all_proposal_types).to match_array(proposal_types_list.pluck(:name, :id))
    end
  end

  describe "#common_proposal_fields" do
    let(:p_type) { create(:proposal_type) }
    let(:p_form) { create(:proposal_form, proposal_type: p_type, status: :active) }
    let(:fields) { create(:proposal_field, :radio_field, proposal_form: p_form) }
    let(:proposal) { create(:proposal, proposal_form: p_form, proposal_type: p_type) }
    it "returns proposal fields" do
      fields
      expect(common_proposal_fields(proposal)).to eq([fields])
    end
  end

  describe '#proposal_ams_subjects_code' do
    let(:proposal) { create :proposal }
    let(:subject_category) { create(:subject_category) }
    let(:subject) { create(:subject, subject_category_id: subject_category.id) }
    let(:ams_subject) do
      create(:ams_subject,
             subject_category_ids: subject_category.id,
             subject_id: subject.id)
    end
    let(:proposal_ams_subject) do
      create(:proposal_ams_subject, proposal: proposal, ams_subject: ams_subject, code: 'code2')
    end

    before do
      proposal.proposal_ams_subjects << proposal_ams_subject
    end

    it 'returns id of proposal ams subject with provided code' do
      expect(proposal_ams_subjects_code(proposal, 'code2')).to eq(ams_subject.id)
    end
  end

  describe "#assigned_dates" do
    context "for valid parameters" do
      let(:location) { create(:location, start_date: '2023-01-29', end_date: '2023-02-17 ') }
      it "returns the range of dates" do
        dates = ["", "2023-01-29 - 2023-02-03",
                 "2023-02-05 - 2023-02-10",
                 "2023-02-12 - 2023-02-17"]

        expect(assigned_dates(location)).to match_array(dates)
      end
    end
    context "when results do not match" do
      let(:location) { create(:location, start_date: '2023-01-29', end_date: '2023-02-17 ') }
      it "returns the range of dates" do
        dates = ["", "2023-02-5 - 2023-02-10"]
        expect(assigned_dates(location)).not_to match_array(dates)
      end
    end
    context "for invalid parameters" do
      let(:location) { create(:location, start_date: "") }
      it "does not return the range of dates" do
        expect(assigned_dates(location)).to match_array([])
      end
    end
  end

  describe "#no_of_participants" do
    context "returns total number of participants" do
      let(:proposal) { create :proposal }
      let(:invites) { create(:invite, proposal_id: proposal.id, invited_as: "Organizer") }
      it 'returns total number of participants' do
        expect(no_of_participants(proposal.id, invites.invited_as))
      end
    end
  end

  describe "#confirmed_participants" do
    context "returns confirmed participants" do
      let(:proposal) { create :proposal }
      let(:invites) { create(:invite, proposal_id: proposal.id, invited_as: "Organizer", status: 'confirmed') }
      it 'returns confirmed participants' do
        expect(confirmed_participants(proposal.id, invites.invited_as))
      end
    end
  end

  describe "#specific proposal statuses" do
    context "returns array of statuses" do
      it 'returns array of specific proposal statuses' do
        expect(specific_proposal_statuses).to be_a Array
      end
    end
  end

  describe "#proposal roles" do
    context "returns proposal roles" do
      let(:proposal_roles) { create(:proposal_role, proposal: proposal) }
      it 'return proposal roles' do
        expect(proposal_roles(proposal_roles))
      end
    end
  end
end
