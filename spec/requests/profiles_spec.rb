require 'rails_helper'

RSpec.describe "/profile", type: :request do
  let(:person) { create(:person) }
  let(:demographic_data) { create(:demographic_data, person: person) }
  let(:user) { create(:user, person: person) }
  before do
    sign_in user
  end

  describe "GET /edit" do
    context 'when editing own profile' do
      context 'with profile_url' do
        before do
          get profile_url
        end

        it { expect(response).to have_http_status(:ok) }
      end

      context 'with edit_profile_url' do
        before do
          get edit_profile_url(person)
        end

        it { expect(response).to have_http_status(:ok) }
      end
    end

    context 'when editing other profile' do
      let(:other_person) { create(:person, firstname: 'Other name') }

      context 'and user is not staff' do
        before do
          get edit_profile_url(other_person)
        end

        it { expect(response).to have_http_status(:ok) }

        it 'show the edit page with the current user profile' do
          expect(response.body).to include(person.firstname)
        end

        it 'does not show the edit page with the other person profile' do
          expect(response.body).not_to include(other_person.firstname)
        end
      end

      context 'when user is staff' do
        before do
          user.roles << create(:role, name: 'Staff')
          get edit_profile_url(other_person)
        end

        it { expect(response).to have_http_status(:ok) }

        it 'show the edit page with the other person profile' do
          expect(response.body).to include(other_person.firstname)
        end
      end
    end
  end

  describe "PATCH /update" do
    let(:person_params) do
      { firstname: 'smith',
        lastname: 'jhones',
        department: 'computer_science' }
    end

    context "with valid parameters" do
      before do
        patch update_url(person), params: { person: person_params }
      end

      it "updates the requested Person" do
        expect(person.reload.lastname).to eq('jhones')
        expect(response).to redirect_to edit_profile_path(person)
      end
    end

    context "with invalid parameters" do
      before do
        params = person_params.merge(firstname: '')
        patch update_url(person), params: { person: params }
      end

      it "does not update Person" do
        expect(response).to redirect_to edit_profile_path(person)
      end
    end
  end

  describe "POST /demographic_data" do
    context "with valid parameters" do
      let(:survey_params) do
        {
          "survey" => { "citizenships" => ["Åland Islands"], "indigenous_person" => "No",
                        "ethnicity" => ["Arab"], "gender" => "Man",
                        "community" => "No", "disability" => "No",
                        "minorities" => "No", "stem" => "Yes", "underRepresented" => "Prefer not to answer" }
        }
      end
      before do
        post demographic_data_path(person), params: { profile_survey: survey_params }
      end

      it "updates the person's demographic_data" do
        expect(response).to redirect_to edit_profile_path(person)
      end
    end

    context "with invalid parameters" do
      let(:survey_params) do
        {
          "survey" => " "
        }
      end

      before do
        post demographic_data_path(person), params: { profile_survey: 'survey_params' }
      end

      it "does not update person's demographic_data" do
        expect(response).to redirect_to edit_profile_path(person)
      end
    end
  end
end
