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

  describe "#proposal_field_partial" do
    let(:field) { create(:proposal_field) }

    it "returns proposal field partial" do
      expect(proposal_field_partial(field)).to eq("proposal_fields/#{field.fieldable_type.split('::').last.underscore}")
    end
  end

  describe "#preferred impossible dates" do
    let(:field) { create(:proposal_field) }

    before do
      field.fieldable.update(statement: "test statement")
    end

    it "returns preferred impossible dates" do
      expect(preferred_impossible_dates(field, "statement")).to eq([["test statement", "test statement"]])
    end
  end

  describe "#options_for_field" do
    let(:single_choice_field) { create(:proposal_field, :single_choice_field) }
    let(:date_field) { create(:proposal_field, :date_field) }
    let(:option1) { create(:option, proposal_field: single_choice_field) }
    let(:option2) { create(:option, proposal_field: single_choice_field, text: 'Female') }

    it 'returns array of option values' do
      option1
      option2
      expect(options_for_field(single_choice_field)).to match_array(%w[Female Male])
    end

    it 'returns field type other than singlechoice,radio,multichoice array' do
      expect(options_for_field(date_field))
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
    let(:locations) { create_list(:location, 4) }
    let!(:proposal_type) { create(:proposal_type, locations: locations) }
    let!(:proposal) { create(:proposal, proposal_type: proposal_type) }
    let!(:field) { create(:proposal_field, :multi_choice_field) }
    let(:version) { create(:proposal_version, proposal_id: proposal.id) }

    it 'It should return because proposal is not present' do
      proposal = nil
      expect(multichoice_answer_with_version(field, proposal, version)).not_to be_present
    end

    context
    let!(:answer_obj) { create(:answer, proposal: proposal, proposal_field: field, version: 1, answer: "[\"YES\"]") }

    it 'It should not return from first line because proposal is present' do
      expect(multichoice_answer_with_version(field, proposal, 1)).to be_present
    end

    it 'It should not return from first line because proposal is present but version is invalid' do
      expect(multichoice_answer_with_version(field, proposal, nil))
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

  describe '#validations' do
    let(:locations) { create_list(:location, 4) }
    let!(:proposal_type) { create(:proposal_type, locations: locations) }
    let!(:proposal) { create(:proposal, proposal_type: proposal_type) }
    let!(:field) { create(:proposal_field, :multi_choice_field) }

    it 'if will return true' do
      field.location_id = 1
      expect(validations(field, proposal))
    end

    it 'if will return false' do
      field.location_id = nil
      expect(validations(field, proposal))
    end
  end

  describe '#mandatory_field?' do
    let(:field) { create :proposal_field, :radio_field }
    let(:invalid_field) { create :proposal_field, nil }
    let(:validations) { create_list(:validation, 4, proposal_field: field) }

    before do
      validations.last.update(validation_type: 'mandatory')
    end

    it 'returns true' do
      expect(mandatory_field?(field)).to include('required')
    end

    it 'returns false' do
      expect(mandatory_field?(invalid_field))
    end
  end

  describe '#location_name' do
    let(:field) { create :proposal_field, :radio_field, :location_based }

    it 'returns location detail' do
      loc = "#{field.location&.name} (#{field.location&.city}, #{field.location&.country})"
      location = "#{loc} - Based question"
      expect(location_name(field)).to eq(location)
    end

    it 'returns no location detail' do
      expect(location_name(field))
    end

    it 'with no location' do
      field.location_id = nil
      expect(location_name(field))
    end
  end

  describe '#answer' do
    let(:locations) { create_list(:location, 4) }
    let!(:proposal_type) { create(:proposal_type, locations: locations) }
    let!(:proposal) { create(:proposal, proposal_type: proposal_type) }
    let!(:field) { create(:proposal_field, :multi_choice_field) }
    let!(:invalid_field) { create(:proposal_field, nil) }

    context 'when proposal is present' do
      let!(:answer_obj) { create(:answer, proposal: proposal, proposal_field: field) }

      it 'It should return an anwser containing proposal and field' do
        expect(answer(field, proposal)).to be_present
      end

      it 'Proposal present but field not present' do
        expect(answer(invalid_field, proposal))
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
  end

  describe '#answer_with_version' do
    let(:locations) { create_list(:location, 4) }
    let!(:proposal_type) { create(:proposal_type, locations: locations) }
    let!(:proposal) { create(:proposal, proposal_type: proposal_type) }
    let!(:field) { create(:proposal_field, :multi_choice_field) }
    let(:version) { create(:proposal_version, proposal_id: proposal.id) }
    let!(:answer_obj) { create(:answer, proposal: proposal, proposal_field: field, version: 1) }

    it 'It should return because proposal is not present' do
      proposal = nil
      expect(answer_with_version(field, proposal, version)).not_to be_present
    end

    it 'It should not return from first line because proposal is present' do
      expect(answer_with_version(field, proposal, 1)).to be_present
    end

    it 'It should not return from first line because proposal is present but version is invalid' do
      expect(answer_with_version(field, proposal, nil))
    end
  end

  describe '#active tab' do
    let!(:proposal) { create(:proposal) }

    it 'when it returns active' do
      param_tab = 'tab-2'
      tab = 'two'
      expect(active_tab(proposal,tab,param_tab)).to eq 'active'
    end

    it 'when it returns ''' do
      param_tab = 'tab-2'
      tab = 'tab'
      expect(active_tab(proposal,tab,param_tab)).to eq ''
    end
  end

  describe '#tab_errors' do
    let(:locations) { create_list(:location, 4) }
    let!(:proposal_type) { create(:proposal_type, locations: locations) }
    let(:subject) { create(:subject) }
    let!(:proposal) { create(:proposal, proposal_type: proposal_type, subject_id: subject.id) }
    let!(:invite) { create(:invite, invited_as: "Organizer", proposal_id: proposal.id) }

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

    context "when tab one returns true" do
      let(:params) do
        { action: 'edit' }
      end
      let!(:ams_subject) { create_list(:ams_subject, 2, subject_id: subject.id) }
      let!(:proposal_ams_subject_one) do
        create(:proposal_ams_subject, proposal_id: proposal.id, ams_subject_id: ams_subject.first.id)
      end
      let!(:proposal_ams_subject_two) do
        create(:proposal_ams_subject, proposal_id: proposal.id, ams_subject_id: ams_subject.second.id)
      end

      it 'when it returns true' do
        param_tab = 'test'
        response = tab_errors(proposal, param_tab)
        invite.update(status: "pending")
        expect(response)
      end

      it 'when it returns false' do
        param_tab = 'test'
        response = tab_errors(proposal, param_tab)
        invite.update(status: "confirmed")
        expect(response)
      end
    end
  end

  describe '#tab_errors' do
    let(:locations) { create_list(:location, 4) }
    let!(:proposal_type) { create(:proposal_type, locations: locations) }
    let(:subject) { create(:subject) }
    let!(:proposal) { create(:proposal, proposal_type: proposal_type, subject_id: subject.id) }

    before do
      param_tab = 'test'
      tab_errors(proposal,param_tab)
    end
    
    it 'when it returns one' do
      expect(tab_one(proposal)).to eq true
    end
  end

  describe '#tab_errors' do
    let(:locations) { create_list(:location, 4) }
    let!(:proposal_type) { create(:proposal_type, locations: locations) }
    let(:subject) { create(:subject) }
    let!(:proposal) { create(:proposal, proposal_type: proposal_type, subject_id: subject.id) }

    before do
      param_tab = 'test'
      tab_errors(proposal,param_tab)
    end
    
    it 'when it returns two' do
      expect(tab_two(proposal)).to eq false
    end
  end

  describe '#tab_errors' do
    let(:locations) { create_list(:location, 4) }
    let!(:proposal_type) { create(:proposal_type, locations: locations) }
    let(:subject) { create(:subject) }
    let!(:proposal) { create(:proposal, proposal_type: proposal_type, subject_id: subject.id) }

    before do
      param_tab = 'test'
      tab_errors(proposal,param_tab)
    end

    it 'when it returns three' do
      expect(tab_three(proposal)).to eq true
    end
  end

  describe '#action' do
    context "when action is show" do
      let(:params) do
        { action: 'show' }
      end

      it 'when it returns true' do
        expect(action).to be_truthy
      end
    end

    context "when action is location_based_fields and request exclude edit" do
      let(:params) do
        { action: 'location_based_fields' }
      end

      it 'when it returns true' do
        expect(action).to eq(nil)
      end
    end
  end

  describe '#disable proposal meeting type' do
    context "when action is show or edit" do
      let(:params) do
        { action: 'show' }
      end

      it 'when it returns true' do
        expect(disable_proposal_meeting_type).to be_truthy
      end
    end

    context "when action is location_based_fields and request exclude edit" do
      let(:params) do
        { action: 'location_based_fields' }
      end

      it 'when it returns true' do
        expect(action).to eq nil
      end
    end
  end

  describe '#tab_one' do
    let(:locations) { create_list(:location, 4) }
    let!(:proposal_type) { create(:proposal_type, locations: locations) }
    let(:subject) { create(:subject) }
    let!(:proposal) { create(:proposal, proposal_type: proposal_type, subject_id: subject.id) }
    let!(:invite) { create(:invite, invited_as: "Organizer", proposal_id: proposal.id) }
    let!(:ams_subject) { create_list(:ams_subject, 2, subject_id: subject.id) }
    let!(:proposal_ams_subject_one) do
      create(:proposal_ams_subject, proposal_id: proposal.id, ams_subject_id: ams_subject.first.id)
    end
    let!(:proposal_ams_subject_two) do
      create(:proposal_ams_subject, proposal_id: proposal.id, ams_subject_id: ams_subject.second.id)
    end

    it 'when it returns false' do
      invite.update(status: "confirmed")
      expect(tab_one(proposal)).to eq false
    end

    it 'when it returns true' do
      invite.update(status: "pending")
      expect(tab_one(proposal)).to eq true
    end
  end

  describe '#tab_two' do
    let!(:locations) { create_list(:location, 4) }
    let!(:proposal_type) { create(:proposal_type, locations: locations) }
    let!(:proposal_form) { create(:proposal_form, status: :active) }
    let!(:proposal) { create(:proposal, proposal_type: proposal_type, proposal_form_id: proposal_form.id) }
    let!(:field) { create(:proposal_field) }

    it 'returns false' do
      field.update(proposal_form_id: proposal_form.id)
      expect(tab_two(proposal)).to eq false
    end

    context 'when error occurs ' do
      let!(:validations) { create(:validation, proposal_field: field) }

      it 'returns true' do
        field.update(proposal_form_id: proposal_form.id)
        expect(tab_two(proposal)).to eq true
      end
    end
  end

  describe '#tab_three' do
    let!(:location) { create_list(:location, 4) }
    let!(:proposal_type) { create(:proposal_type, locations: location) }
    let!(:proposal_form) { create(:proposal_form, status: :active) }
    let!(:proposal) { create(:proposal, proposal_type: proposal_type, proposal_form_id: proposal_form.id) }
    let!(:new_location) { create(:location) }
    let!(:field) { create(:proposal_field, location: new_location) }

    context 'return true when location is empty' do
      it 'return true' do
        field.update(proposal_form_id: proposal_form.id)
        expect(tab_three(proposal)).to eq true
      end
    end

    context ' return false when errors.flatten.count != 1' do
      let!(:proposal_location) { create(:proposal_location, location: new_location, proposal: proposal) }
      let!(:proposal_field) { create(:proposal_field, location_id: proposal_location) }

      it 'returns false' do
        field.update(proposal_form_id: proposal_form.id)
        expect(tab_three(proposal)).to eq false
      end
    end

    context 'return true when errors.flatten.count == 1' do
      let!(:proposal_location) { create(:proposal_location, location: new_location, proposal: proposal) }
      let!(:proposal_field) { create(:proposal_field, location_id: proposal_location) }
      let!(:validations) { create(:validation, proposal_field: field) }

      it 'returns true' do
        field.update(proposal_form_id: proposal_form.id)
        expect(tab_three(proposal)).to eq true
      end
    end
  end

  describe '#dates_answer' do
    let(:locations) { create_list(:location, 4) }
    let!(:proposal_type) { create(:proposal_type, locations: locations) }
    let!(:proposal) { create(:proposal, proposal_type: proposal_type) }
    let!(:field) { create(:proposal_field, :multi_choice_field) }
    let!(:answer_obj) { create(:answer, proposal: proposal, proposal_field: field, answer: "[\"YES\"]") }

    it 'if will return true' do
      expect(dates_answer(field, proposal, 1))
    end

    context 'when answer is not present' do
      let!(:answer_obj) { create(:answer, proposal: proposal, proposal_field: field, answer: nil) }

      it 'if will return false' do
        expect(dates_answer(field, proposal, 1))
      end
    end
  end

  describe '#dates_answer_version' do
    let(:locations) { create_list(:location, 4) }
    let!(:proposal_type) { create(:proposal_type, locations: locations) }
    let!(:proposal) { create(:proposal, proposal_type: proposal_type) }
    let!(:field) { create(:proposal_field, :multi_choice_field) }
    let(:version) { create(:proposal_version, proposal_id: proposal.id) }
    let!(:answer_obj) { create(:answer, proposal: proposal, proposal_field: field, version: 1, answer: "[\"YES\"]") }

    it 'if will return true' do
      expect(dates_answer_with_version(field, proposal, 1, 1))
    end

    context 'when answer is not present' do
      let!(:answer_obj) { create(:answer, proposal: proposal, proposal_field: field, answer: nil, version: 1) }
      it 'if will return false' do
        expect(dates_answer_with_version(field, proposal, 1, version))
      end
    end
  end

  describe '#answer_obj' do
    let(:locations) { create_list(:location, 4) }
    let!(:proposal_type) { create(:proposal_type, locations: locations) }
    let!(:proposal) { create(:proposal, proposal_type: proposal_type) }
    let!(:field) { create(:proposal_field, :multi_choice_field) }

    it 'if will return false' do
      expect(answer_obj(field, nil))
    end

    it 'if will return true' do
      expect(answer_obj(field, proposal))
    end
  end

  describe '#can_edit' do
    let(:params) do
      { action: 'edit' }
    end
    let!(:location) { create_list(:location, 4) }
    let!(:proposal_type) { create(:proposal_type, locations: location) }
    let!(:proposal_form) { create(:proposal_form, status: :active) }

    let(:person) { create(:person) }
    let(:role) { create(:role, name: 'Staff') }
    let(:current_user) { create(:user, person: person) }
    let(:role_privilege) do
      create(:role_privilege,
             permission_type: "Manage", privilege_name: "Invite", role_id: role.id)
    end
    let(:role_privilege1) do
      create(:role_privilege,
             permission_type: "Manage", privilege_name: "SubmittedProposalsController", role_id: role.id)
    end

    before do
      role_privilege
      current_user.roles << role
    end

    it 'with current user' do
      expect(can_edit(proposal_form))
    end

    context "with no current user" do
      let(:current_user) { create(:user, person: nil) }

      it 'with no current user' do
        expect(can_edit(proposal_form))
      end
    end
  end

  describe '#can_edit' do
    let(:person) { create(:person) }
    let(:role) { create(:role, name: 'Staff') }
    let(:current_user) { create(:user, person: person) }
    let(:role_privilege) do
      create(:role_privilege,
             permission_type: "Manage", privilege_name: "ProposalForm", role_id: role.id)
    end
    let!(:proposal_form) { create(:proposal_form, status: "draft") }
    let(:params) do
      { action: 'edit' }
    end

    before do
      role_privilege
      current_user.roles << role
    end

    it 'if will return true if status present and action is edit' do
      expect(can_edit(proposal_form)).to be_truthy
    end
  end
end
