require 'rails_helper'

RSpec.describe "/proposal_types", type: :request do
  let(:proposal_type) { create(:proposal_type) }

  describe "GET /index" do
    context 'for non-staff' do
      it 'forwards to proposals_path' do
        get proposal_types_url

        expect(response).to have_http_status(:redirect)
      end
    end

    context 'for staff' do
      it 'responds OK' do
        authenticate_for_controllers
        get proposal_types_url

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_proposal_type_url
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /edit" do
    it "render a successful response" do
      get edit_proposal_type_url(proposal_type)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:proposal_type_params) do
        { name: '2 Day Workshop', year: '2015,2016,2017', participant: '1', co_organizer: '1', code: '2021xx2',
          open_date: Time.current.to_date, closed_date: Time.current.to_date + 1.week, max_no_of_preferred_dates: 2,
          min_no_of_preferred_dates: 2, max_no_of_impossible_dates: 2, min_no_of_impossible_dates: 2,
          participant_description: 'some participants description',
          organizer_description: 'some organizers description',
          capacity: 42 }
      end
      it "creates a new proposal_type" do
        expect do
          post proposal_types_url, params: { proposal_type: proposal_type_params }
        end.to change(ProposalType, :count).by(1)
      end
    end

    context "with invalid parameters" do
      let(:proposal_type_params) do
        { name: ' ', participant: '1', co_organizer: '1', code: '2021xx2', open_date: Time.current.to_date,
          closed_date: Time.current.to_date + 1.week,
          participant_description: 'some participants description',
          organizer_description: 'some organizers description',
          min_no_of_preferred_dates: 2, max_no_of_preferred_dates: 4,
          min_no_of_impossible_dates: 1, max_no_of_impossible_dates: 2 }
      end

      it "does not create a new proposal_type" do
        expect do
          post proposal_types_url, params: { proposal_type: proposal_type_params }
        end.to change(ProposalType, :count).by(0)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:proposal_type_params) { { name: '5 Day Workshop', year: '2021,2022,2023' } }

      before do
        patch proposal_type_url(proposal_type), params: { proposal_type: proposal_type_params }
      end
      it "updates the requested proposal_type" do
        expect(proposal_type.reload.name).to eq('5 Day Workshop')
      end
    end

    context "with invalid parameters" do
      let(:proposal_type_params) { { name: ' ', year: '2012,2013,2014' } }

      before do
        patch proposal_type_url(proposal_type), params: { proposal_type: proposal_type_params }
      end
      it "renders a successful response (i.e. to display the 'edit' template)" do
        expect(response).to redirect_to(edit_proposal_type_url(proposal_type))
      end
    end
  end

  describe "DELETE /destroy" do
    before do
      delete proposal_type_url(proposal_type.id)
    end
    it { expect(ProposalType.all.count).to eq(0) }
  end

  describe "GET /proposal_type_locations" do
    before do
      locations = create_list(:location, 4)
      proposal_type.locations << locations
      get proposal_type_locations_proposal_type_url(proposal_type)
    end
    it 'returns list of locations' do
      expect(JSON.parse(response.body).length).to eq(4)
    end
  end

  describe "GET /location_based_fields" do
    let(:proposal) { create(:proposal) }
    let(:proposal_form) { create(:proposal_form, status: :active, proposal_type: proposal_type) }
    let(:proposal_field) { create(:proposal_field, :radio_field, :location_based, proposal_form: proposal_form) }
    before do
      proposal_field
      get location_based_fields_proposal_type_url(proposal_type, ids: [proposal_field.location.id],
                                                                 proposal_id: proposal.id)
    end
    it { expect(response).to have_http_status(:ok) }
  end
end
