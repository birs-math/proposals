require 'rails_helper'

RSpec.describe "/schedules", type: :request do
  let(:location) { create(:location) }
  let(:role) { create(:role, name: 'Staff') }
  let(:schedule_run) { create(:schedule_run) }
  let(:schedules) { create_list(:schedule, 2, schedule_run_id: schedule_run.id) }

  let(:role_privilege_controller) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "SchedulesController",
           role_id: role.id)
  end

  before do
    authenticate_for_controllers # signs-in @user
    role_privilege_controller
    @user.roles << role
  end

  describe "GET /new" do
    it "render a successful response" do
      get new_schedule_url
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    it "render a successful response when request format is not json" do
      post '/schedules'
      expect(response).to have_http_status(406)
    end
  end

  describe "POST /create" do
    it "render a successful response when no API key present" do
      ENV['SCHEDULE_API_KEY'] = ''
      post '/schedules', params: {
                           some_field: "test"
                         },
                         as: :json
      expect(response).to have_http_status(401)
    end
  end

  describe "POST /create" do
    it "render a successful response when API key is invalid" do
      ENV['SCHEDULE_API_KEY'] = 'test'
      post '/schedules', params: {
                           schedule: {
                             SCHEDULE_API_KEY: "test_invalid"
                           }
                         },
                         as: :json
      expect(response).to have_http_status(401)
    end
  end

  describe "POST /create" do
    it "render a successful response when API key is valid and record not saved" do
      ENV['SCHEDULE_API_KEY'] = 'test'
      post '/schedules', params: {
                           schedule: {
                             SCHEDULE_API_KEY: "test",
                             schedule_run_id: schedule_run.id,
                             run_data: [
                               case_num: 1,
                               hmc_score: 2,
                               assignments: %w[one two]
                             ]
                           }
                         },
                         as: :json
      expect(response).to have_http_status(422)
    end
  end

  describe "POST /create" do
    it "render a successful response when API key is valid and record saved successfully" do
      ENV['SCHEDULE_API_KEY'] = 'test'
      post '/schedules', params: {
                           schedule: {
                             SCHEDULE_API_KEY: "test",
                             schedule_run_id: schedule_run.id,
                             run_data: [
                               case_num: 1,
                               hmc_score: 2,
                               assignments: [week: "1", proposal: "ss"]
                             ]
                           }
                         },
                         as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /optimized_schedule" do
    context 'when page is not present in params' do
      let(:params) do
        {
          run_id: schedule_run.id
        }
      end
      it "render a successful response" do
        schedules.first.update(case_num: 1)
        get optimized_schedule_schedules_url, params: params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when page is present in params and it is a positive integer' do
      let(:params) do
        {
          run_id: schedule_run.id,
          page: 2
        }
      end
      it "render a successful response" do
        schedules.first.update(case_num: 2)
        get optimized_schedule_schedules_url, params: params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when page is present in params and it is 0' do
      let(:params) do
        {
          run_id: schedule_run.id,
          page: 0
        }
      end
      it "render a successful response" do
        schedules.first.update(case_num: 1)
        get optimized_schedule_schedules_url, params: params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when page is present in params and it is more than schedule_run cases' do
      let(:params) do
        {
          run_id: schedule_run.id,
          page: 8
        }
      end
      it "render a successful response" do
        schedules.first.update(case_num: 6)
        get optimized_schedule_schedules_url, params: params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when no shedules found in response' do
      let(:params) do
        {
          run_id: schedule_run.id,
          page: 8
        }
      end
      it "render a successful response" do
        schedules.first.update(case_num: 1)
        get optimized_schedule_schedules_url, params: params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when no dates present schedules found in response' do
      let(:params) do
        {
          run_id: schedule_run.id,
          page: 8
        }
      end
      it "render a successful response" do
        schedules.first.update(case_num: 6)
        schedule_run.location.update(start_date: nil)
        get optimized_schedule_schedules_url, params: params
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /export_scheduled_proposals_schedules" do
    context 'when schedule proposal is not match with w66' do
      let(:params) do
        {
          run_id: schedule_run.id,
          case: 1
        }
      end
      it "render a successful response" do
        schedules.first.update(case_num: 1)
        post export_scheduled_proposals_schedules_url, params: params
        expect(response).to have_http_status(302)
        expect(response).to redirect_to new_schedule_path
      end
    end

    context "when schedule proposal is not match with w66 but have ' and ' in it" do
      let(:params) do
        {
          run_id: schedule_run.id,
          case: 1
        }
      end
      it "render a successful response no proposal found with code" do
        schedules.first.update(case_num: 1, proposal: 'abc and xyz')
        schedules.first.update(case_num: 1)
        post export_scheduled_proposals_schedules_url, params: params
        expect(response).to have_http_status(302)
        expect(response).to redirect_to new_schedule_path
      end
    end

    describe ' when proposal found with code' do
      let!(:proposal_first) { create(:proposal, code: 'abc') }
      let!(:proposal_second) { create(:proposal, code: 'xyz') }

      context "when schedule proposal is not match with w66 but have ' and ' in it" do
        let(:params) do
          {
            run_id: schedule_run.id,
            case: 1
          }
        end
        it "render a successful response" do
          schedules.first.update(case_num: 1, proposal: 'abc and xyz')
          schedules.first.update(case_num: 1)
          post export_scheduled_proposals_schedules_url, params: params
          expect(response).to have_http_status(302)
          expect(response).to redirect_to new_schedule_path
        end
      end
    end

    context 'when schedule proposal is not match with w66' do
      let(:params) do
        {
          run_id: schedule_run.id,
          case: 1
        }
      end
      it "render a successful response" do
        schedules.first.update(case_num: 1, proposal: 'w66')
        post export_scheduled_proposals_schedules_url, params: params
        expect(response).to have_http_status(302)
        expect(response).to redirect_to new_schedule_path
      end
    end

    context 'when schedules required proposal is not found' do
      let(:params) do
        {
          run_id: schedule_run.id,
          case: 1
        }
      end
      it "render a successful response" do
        schedules.first.update(case_num: 1, proposal: ' ')
        post export_scheduled_proposals_schedules_url, params: params
        expect(response).to have_http_status(302)
        expect(response).to redirect_to new_schedule_path
      end
    end

    context 'when no required schedule is present' do
      let(:params) do
        {
          run_id: schedule_run.id,
          case: 1
        }
      end
      it "render a successful response" do
        schedules.first.update(case_num: 2)
        post export_scheduled_proposals_schedules_url, params: params
        expect(response).to have_http_status(302)
        expect(response).to redirect_to new_schedule_path
      end
    end
  end

  describe "GET /download_csv" do
    context 'when schedule run is blank' do
      it 'should redirect and return' do
        get download_csv_schedules_url
        expect(response).to have_http_status(302)
        expect(response).to redirect_to new_schedule_path
      end
    end

    context 'when schedule run is present case_num is not in params' do
      let(:params) do
        {
          run_id: schedule_run.id
        }
      end
      it 'should redirect and return' do
        get download_csv_schedules_url, params: params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when schedule run is present case_num is in params' do
      let(:params) do
        {
          run_id: schedule_run.id,
          case_num: 2
        }
      end
      it 'should redirect and return' do
        get download_csv_schedules_url, params: params
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /form" do
    it "render a successful response" do
      get new_schedule_run_schedules_url, params: { location: location.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /run_hmc_program" do
    context "when schedule run save successfully" do
      let(:params) do
        {
          location_id: location.id,
          year: Date.current.year + 2,
          weeks: 5,
          runs: 5000,
          cases: 10,
          test_mode: false
        }
      end

      it "calls hmc job" do
        post run_hmc_program_schedules_url, params: params
        expect(response).to have_http_status(422)
      end
    end

    context "when schedule run does not save successfully" do
      let(:params) do
        {
          location_id: location.id,
          year: Date.current.year + 2,
          weeks: 5,
          runs: 5000,
          test_mode: false
        }
      end

      it "render a unsuccessful response" do
        post run_hmc_program_schedules_url, params: params
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'choice' do
    context 'When proposal is blank' do
      let(:proposal) { create :proposal }
      let(:schedule_run) { create :schedule_run }
      let(:schedule) { create :schedule, schedule_run_id: schedule_run.id, proposal: nil }

      it 'returns nill' do
        expect(schedule.choice).to eq("")
      end
    end

    context 'When proposal preferred dates are blank' do
      let(:proposal) { create :proposal }
      let(:schedule) { create :schedule, schedule_run_id: schedule_run.id, proposal: nil }
      it 'returns nill' do
        expect(proposal.preferred_dates).to eq('')
      end
    end
  end

  describe 'dates' do
    context 'When no of weeks is zero' do
      let(:proposal) { create :proposal }
      let(:location) { create(:location, end_date: "") }
      let(:schedule_run) { create(:schedule_run, location_id: location.id) }
      let(:schedule) { create(:schedule, schedule_run_id: schedule_run.id) }

      it 'returns empty array' do
        expect(schedule.dates).to match_array([])
      end
    end

    context 'When no of weeks is not zero' do
      let(:proposal) { create :proposal }
      let(:location) { create(:location) }
      let(:schedule_run) { create(:schedule_run, location_id: location.id) }
      let(:schedule) { create(:schedule, schedule_run_id: schedule_run.id) }

      let(:output) do
        '[Sun, 08 Jan 2023, Sun, 15 Jan 2023, Sun, 22 Jan 2023, Sun, 29 Jan 2023, Sun, 05 Feb 2023, Sun, 12 Feb 2023,
        Sun, 19 Feb 2023]'
      end

      it 'returns empty array' do
        location
        expect(schedule.dates.to_s).to be_a String
      end
    end
  end
end
