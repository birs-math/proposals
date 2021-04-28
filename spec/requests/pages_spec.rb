require 'rails_helper'

RSpec.describe "/pages", type: :request do
  describe "GET guidelines" do
    before do
      get guidelines_url
    end
    it { expect(response).to have_http_status(:ok) }
  end
end
