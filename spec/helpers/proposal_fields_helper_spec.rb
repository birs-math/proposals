require 'rails_helper'

RSpec.describe ProposalFieldsHelper, type: :helper do
  describe "#proposal_type_locations" do
    let(:locations) { create_list(:location, 2) }
    let(:proposal_type) { create(:proposal_type, locations: locations) }

    it "returns locations of a proposal type" do
      proposal_type_locations(proposal_type).each do |location|
        loc = proposal_type.locations.where(id: location.last).first
        location_string = "#{loc.name} (#{loc.city}, #{loc.country})"
        expect(location.first).to eq(location_string)
      end
    end
  end

  describe "#proposal_field_options" do
    let(:radio_field) { create(:proposal_field, :radio_field) }
    let(:option) { create(:option, proposal_field: radio_field) }

    it "returns array of options value and text" do
      option
      expect(proposal_field_options(radio_field)).to match_array([%w[Male M]])
    end

    it 'returns empty array' do
      expect(proposal_field_options(radio_field)).to match_array([])
    end
  end

  describe "#options_for_field" do
    let(:single_choice_field) { create(:proposal_field, :single_choice_field) }
    let(:option1) { create(:option, proposal_field: single_choice_field) }
    let(:option2) { create(:option, proposal_field: single_choice_field, text: 'Female') }

    it 'returns array of option values' do
      option1
      option2
      expect(options_for_field(single_choice_field)).to match_array(%w[Female Male])
    end

    it 'returns empty array' do
      expect(options_for_field(single_choice_field)).to match_array([])
    end
  end

  describe "#multichoice_answer" do
    let(:proposal) { create(:proposal) }
    let(:proposal) { create(:proposal) }
    let(:field) { create(:proposal_field, :multi_choice_field) }

    context 'when multichoice filed has answer' do
      let(:answer) { create(:answer, proposal: proposal, proposal_field: field, answer: "[\"YES\"]") }
      it 'returns option' do
        answer
        expect(multichoice_answer(field, proposal)).to match_array('YES')
      end
    end

    context 'when multichoice filed has no answer' do
      let(:answer) { build(:answer, proposal: proposal, proposal_field: field, answer: '') }

      it 'returns nil' do
        answer
        expect(multichoice_answer(field, proposal)).to eq(nil)
      end

      it 'returns when proposal is not present' do
        answer
        proposal = nil
        expect(multichoice_answer(field, proposal)).to eq(nil)
      end
    end
  end

  describe "#multichoice_answer_with_version" do
    let(:proposal) { create(:proposal) }
    let(:proposal) { create(:proposal) }
    let(:field) { create(:proposal_field, :multi_choice_field) }
    let!(:version) { create(:proposal_version, proposal_id: proposal.id) }

    context 'when multichoice filed has no answer' do
      let!(:answer) { build(:answer, proposal: proposal, proposal_field: field, answer: '') }

      it 'returns nil' do
        expect(multichoice_answer_with_version(field, proposal, version)).to eq(nil)
      end

      it 'returns when proposal is not present' do
        answer
        proposal = nil
        expect(multichoice_answer_with_version(field, proposal, version)).to eq(nil)
      end
    end
  end

  describe '#location_in_answers' do
    let(:locations) { create_list(:location, 4) }
    let(:proposal_type) { create(:proposal_type, locations: locations) }
    let(:proposal) { create(:proposal, proposal_type: proposal_type) }

    it 'returns location ids for proposal fields' do
      expect(location_in_answers(proposal)).to match_array(proposal.locations.map(&:id))
    end
  end

  describe '#mandatory_field?' do
    let(:field) { create :proposal_field, :radio_field }
    let(:validations) { create_list(:validation, 4, proposal_field: field) }

    before do
      validations.last.update(validation_type: 'mandatory')
    end

    it 'returns true' do
      expect(mandatory_field?(field)).to include('required')
    end
  end

  describe '#location_name' do
    let(:field) { create :proposal_field, :radio_field, :location_based }
    it 'returns location detail' do
      loc = "#{field.location&.name} (#{field.location&.city}, #{field.location&.country})"
      location = "#{loc} - Based question"
      expect(location_name(field)).to eq(location)
    end
  end

  describe '#answer' do
    let(:locations) { create_list(:location, 4) }
    let!(:proposal_type) { create(:proposal_type, locations: locations) }
    let!(:proposal) { create(:proposal, proposal_type: proposal_type) }
    let!(:field) { create(:proposal_field, :multi_choice_field) }

    context 'when proposal is present' do
      let!(:answer_obj) { create(:answer, proposal: proposal, proposal_field: field) }

      it 'It should return an anwser containing proposal and field' do
        expect(answer(field, proposal)).to be_present
      end
      it 'expecting a string response' do
        expect(answer(field, proposal)).to be_a(String)
      end
    end

    context 'when proposal is not present' do
      proposal = nil
      it 'It should return an anser containing proposal and field' do
        expect(answer(field, proposal)).not_to be_present
      end
    end

    context '#answer_with_version' do
      let(:version) { create(:proposal_version, proposal_id: proposal.id) }
      let!(:answer_obj) { create(:answer, proposal: proposal, proposal_field: field) }

      it 'It should return because proposal is not present' do
        proposal = nil
        expect(answer_with_version(field, proposal, version)).not_to be_present
      end

      it 'It should not return from first line because proposal is present' do
        expect(answer_with_version(field, proposal, version)).not_to be_present
      end
    end
  end

  describe '#tab_errors' do
    let(:locations) { create_list(:location, 4) }
    let!(:proposal_type) { create(:proposal_type, locations: locations) }
    let!(:proposal) { create(:proposal, proposal_type: proposal_type) }
    it 'when it returns two' do
      param_tab = 'tab-2'
      response = tab_errors(proposal, param_tab)
      expect(response).to be_a String
      expect(response).to eq 'two'
    end
    it 'when it returns one without params passing' do
      param_tab = 'test'
      response = tab_errors(proposal, param_tab)
      expect(response).to be_a String
      expect(response).to eq 'one'
    end
  end

  describe '#tab_one' do
    let(:locations) { create_list(:location, 4) }
    let!(:proposal_type) { create(:proposal_type, locations: locations) }
    let!(:proposal) { create(:proposal, proposal_type: proposal_type) }
    let(:invite) { create(:invite, invited_as: "Organizer", proposal_id: proposal.id) }
    it 'when it returns true' do
      expect(tab_one(proposal)).to eq true
    end
  end

  describe '#tab_two' do
    let!(:locations) { create_list(:location, 4) }
    let!(:proposal_type) { create(:proposal_type, locations: locations) }
    let!(:proposal) { create(:proposal, proposal_type: proposal_type) }
    let!(:proposal_form) { create(:proposal_form, status: :active) }
    let!(:proposal_field) { create(:proposal_field, :radio_field, :location_based, proposal_form: proposal_form) }
    it 'when it returns false and does not enter in loop' do
      expect(tab_two(proposal)).to eq false
    end

    it '#tab_three when it returns true with empty locations and does not enter in loop' do
      expect(tab_three(proposal)).to eq true
    end

    it '#tab_three does not enter in loop and returns false' do
      proposal.update(location_ids: [locations.first.id])
      expect(tab_three(proposal)).to eq false
    end
  end
end
