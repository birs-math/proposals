require 'rails_helper'

RSpec.describe "/survey", type: :request do
  let(:proposal_type) { create(:proposal_type) }
  let(:proposal) { create(:proposal, proposal_type: proposal_type) }
  let(:invite) { create(:invite, proposal: proposal) }
  let(:person) { create(:person) }
  let(:role) { create(:role, name: 'Staff') }
  let(:user) { create(:user, person: person) }
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
    user.roles << role
    sign_in user
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_survey_path(code: invite.code)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /survey_questionnaire" do
    it "renders a successful response" do
      get survey_questionnaire_survey_index_path(code: invite.code)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /pre_load_survey_questionnaire" do
    context "with response empty" do
      let(:demographic_data) { create(:demographic_data, person_id: person.id) }
      let(:params) do
        { id: demographic_data.id,
          code: invite.code,
          response: '',
          pre_load_survey_questionnaire_survey_index: demographic_data.result }
      end
      it "when is_invited_person is set to true in session" do
        session_mock(is_invited_person: 'true')
        post pre_load_survey_questionnaire_survey_index_path(params: params)
        expect(response).to have_http_status(302)
      end
    end

    context "with response yes" do
      let(:demographic_data) { create(:demographic_data, person_id: person.id) }
      let(:params) do
        { id: demographic_data.id,
          code: invite.code,
          response: 'yes',
          pre_load_survey_questionnaire_survey_index: demographic_data.result }
      end
      it "when is_invited_person is not set to true in session" do
        post pre_load_survey_questionnaire_survey_index_path(params: params)
        expect(response).to have_http_status(302)
      end
    end
  end

  describe "GET /submit_survey_without_response" do
    let(:demographic_data) { create(:demographic_data, person_id: person.id) }
    context "with empty response" do
      let(:params) do
        { code: invite.code,
          response: '',
          id: demographic_data.id,
          survey: { "citizenships" => ["", "Prefer not"],
                    "citizenships_other" => "",
                    "indigenous_person" => "No",
                    "indigenous_person_yes" => [""],
                    "ethnicity" => ["", "Arab"],
                    "ethnicity_other" => "",
                    "gender" => "Man", "gender_other" => "",
                    "community" => "No", "disability" => "No",
                    "minorities" => "Yes", "stem" => "Yes",
                    "underRepresented" => "Yes" } }
      end

      it "when is_invited_person is set to true in session" do
        session_mock(is_invited_person: 'true')
        get submit_survey_without_response_survey_index_path(params: params)
        expect(response).to have_http_status(302)
      end
    end

    context "with response yes" do
      let(:demographic_data) { create(:demographic_data, person_id: person.id) }
      let(:params) do
        { id: demographic_data.id,
          code: invite.code,
          response: 'yes',
          survey: { "citizenships" => ["", "Prefer not"],
                    "citizenships_other" => "",
                    "indigenous_person" => "No",
                    "indigenous_person_yes" => [""],
                    "ethnicity" => ["", "Arab"],
                    "ethnicity_other" => "",
                    "gender" => "Man", "gender_other" => "",
                    "community" => "No", "disability" => "No",
                    "minorities" => "Yes", "stem" => "Yes",
                    "underRepresented" => "Yes" } }
      end
      it "when is_invited_person is not set to true in session" do
        get submit_survey_without_response_survey_index_path(params: params)
        expect(response).to have_http_status(302)
      end
    end
    
  end

  describe "GET /faqs" do
    let(:faqs) { create_list(:faq, 4) }
    it "renders a successful response" do
      get faqs_survey_index_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /submit_survey" do
    context "with array parameters" do
      let(:params) do
        { code: invite.code,
          response: 'yes',
          survey: { "citizenships" => ["", "Prefer not"],
                    "citizenships_other" => "",
                    "indigenous_person" => "No",
                    "indigenous_person_yes" => [""],
                    "ethnicity" => ["", "Arab"],
                    "ethnicity_other" => "",
                    "gender" => "Man", "gender_other" => "",
                    "community" => "No", "disability" => "No",
                    "minorities" => "Yes", "stem" => "Yes",
                    "underRepresented" => "Yes" } }
      end
      let(:demographic_data) { build(:demographic_data, person_id: invite.person) }

      before do
        invite.update(status: 'confirmed')
        post submit_survey_survey_index_path(params: params)
      end

      it "renders a successful response" do
        expect(response).to have_http_status(:found)
      end
    end
  end

  context "with string parameters" do
    let(:params) do
      { code: invite.code,
        response: invite.response,
        survey: { "citizenships" => "Prefer not",
                  "citizenships_other" => "",
                  "indigenous_person" => "No",
                  "indigenous_person_yes" => "",
                  "ethnicity" => "Arab",
                  "ethnicity_other" => "",
                  "gender" => "Man", "gender_other" => "",
                  "community" => "No", "disability" => "No",
                  "minorities" => "Yes", "stem" => "Yes",
                  "underRepresented" => "Yes" } }
    end

    let(:demographic_data) { build(:demographic_data, person_id: 0) }

    before do
      invite.update(status: 'confirmed')
      session_mock(is_invited_person: 'true')
    end

    it "renders a successful response" do
      post submit_survey_survey_index_path(params: params)
      expect(response).to have_http_status(:found)
    end
  end

  context "with invite nill" do
    let(:params) do
      { code: nil,
        response: invite.response,
        survey: { "citizenships" => "Prefer not",
                  "citizenships_other" => "",
                  "indigenous_person" => "No",
                  "indigenous_person_yes" => "",
                  "ethnicity" => "Arab",
                  "ethnicity_other" => "",
                  "gender" => "Man", "gender_other" => "",
                  "community" => "No", "disability" => "No",
                  "minorities" => "Yes", "stem" => "Yes",
                  "underRepresented" => "Yes" } }
    end

    let(:demographic_data) { build(:demographic_data, person_id: 0) }

    before do
      invite.update(status: 'confirmed')
      session_mock(is_invited_person: 'true')
    end

    it "renders a successful response" do
      post submit_survey_survey_index_path(params: params)
      expect(response).to have_http_status(:found)
    end
  end

  context "with invite nill" do
    let(:params) do
      { code: invite.code,
        response: "",
        survey: { "citizenships" => "Prefer not",
                  "citizenships_other" => "",
                  "indigenous_person" => "No",
                  "indigenous_person_yes" => "",
                  "ethnicity" => "Arab",
                  "ethnicity_other" => "",
                  "gender" => "Man", "gender_other" => "",
                  "community" => "No", "disability" => "No",
                  "minorities" => "Yes", "stem" => "Yes",
                  "underRepresented" => "Yes" } }
    end

    let(:demographic_data) { build(:demographic_data, person_id: 0) }

    before do
      invite.update(status: 'confirmed')
      session_mock(is_invited_person: 'true')
    end

    it "renders a successful response" do
      post submit_survey_survey_index_path(params: params)
      expect(response).to have_http_status(:found)
    end
  end

  context "with invalid demographic_data" do
    let(:user) { create(:user, person: nil) }
    let(:params) do
      { code: nil,
        response: invite.response,
        survey: { "citizenships" => "Prefer not",
                  "citizenships_other" => "",
                  "indigenous_person" => "No",
                  "indigenous_person_yes" => "",
                  "ethnicity" => "Arab",
                  "ethnicity_other" => "",
                  "gender" => "Man", "gender_other" => "",
                  "community" => "No", "disability" => "No",
                  "minorities" => "Yes", "stem" => "Yes",
                  "underRepresented" => "Yes" } }
    end

    let(:demographic_data) { build(:demographic_data, person_id: nil) }

    before do
      invite.update(status: 'confirmed')
      session_mock(is_invited_person: 'true')
    end

    it "renders a successful response" do
      post submit_survey_survey_index_path(params: params)
      expect(response).to have_http_status(:found)
    end
  end

  context "with no current user" do
    let(:user) { create(:user, person: nil) }
    let(:params) do
      { code: invite.code,
        response: invite.response,
        survey: { "citizenships" => "Prefer not",
                  "citizenships_other" => "",
                  "indigenous_person" => "No",
                  "indigenous_person_yes" => "",
                  "ethnicity" => "Arab",
                  "ethnicity_other" => "",
                  "gender" => "Man", "gender_other" => "",
                  "community" => "No", "disability" => "No",
                  "minorities" => "Yes", "stem" => "Yes",
                  "underRepresented" => "Yes" } }
    end

    let(:demographic_data) { build(:demographic_data, person_id: invite.person) }

    before do
      invite.update(status: 'confirmed')
      session_mock(is_invited_person: 'true')
    end

    it "renders a successful response" do
      post submit_survey_survey_index_path(params: params)
      expect(response).to have_http_status(:found)
    end
  end

  context "with no invite person" do
    let(:params) do
      { code: nil,
        response: invite.response,
        survey: { "citizenships" => "Prefer not",
                  "citizenships_other" => "",
                  "indigenous_person" => "No",
                  "indigenous_person_yes" => "",
                  "ethnicity" => "Arab",
                  "ethnicity_other" => "",
                  "gender" => "Man", "gender_other" => "",
                  "community" => "No", "disability" => "No",
                  "minorities" => "Yes", "stem" => "Yes",
                  "underRepresented" => "Yes" } }
    end

    let(:demographic_data) { build(:demographic_data, person_id: nil) }

    before do
      invite.update(status: 'confirmed')
      session_mock(is_invited_person: 'true')
    end

    it "renders a successful response" do
      post submit_survey_survey_index_path(params: params)
      expect(response).to have_http_status(:found)
    end
  end
end
