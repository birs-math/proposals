require 'rails_helper'

RSpec.describe ProposalType, type: :model do
  describe 'validations' do
    it 'has valid factory' do
      expect(build(:proposal_type)).to be_valid
    end
  end

  describe 'associations' do
    it { should have_many(:proposals).dependent(:destroy) }
    it { should have_many(:proposal_forms).dependent(:destroy) }
    it { should have_many(:proposal_type_locations).dependent(:destroy) }
    it { should have_many(:locations).through(:proposal_type_locations) }
  end

  describe '#active_form' do
    let(:proposal_type) { create(:proposal_type)}
    let!(:proposal_forms) { create_list(:proposal_form, 3, status: 1, proposal_type: proposal_type) }

    it 'expecting' do
      response = proposal_type.active_form
      expect(response).to eq(proposal_forms.first)
    end
  end

  describe 'open_date validations' do
    let(:proposal_type) { create(:proposal_type)}

    context 'when open_date is nil' do
      it 'has nil response' do
        proposal_type.update(open_date: nil)
        response = proposal_type.not_closed_date_greater

        expect(response).to eq(nil)
      end
    end

    context 'when open_date > closed_date' do
      let(:open_date) { Date.today + 10.days }

      it 'expecting' do
        proposal_type.update(open_date: open_date)

        expect(proposal_type.errors.full_messages)
          .to eq(["Open date  #{open_date} - cannot be greater than Closed Date #{proposal_type.closed_date.to_date}"])
      end
    end

    context 'when open_date == closed_date' do
      let(:today) { Date.today }

      it 'expecting' do
        proposal_type.update(open_date: today, closed_date: today)

        expect(proposal_type.errors.full_messages)
          .to eq(["Open date  #{today} - cannot be same as Closed Date #{today}"])
      end
    end
  end

  describe 'max_preferred_greater_than_min_preferred' do
    let(:proposal_type) { create(:proposal_type)}

    it 'expecting' do
      proposal_type.update(min_no_of_preferred_dates: 3)

      expect(proposal_type.errors.full_messages.last)
        .to eq("Minimum number of preferred dates can not be greater than maximum number of preferred dates")
    end
  end

  describe 'max_preferred_greater_than_min_preferred' do
    let(:proposal_type) { create(:proposal_type)}

    it 'expecting' do
      proposal_type.update(min_no_of_impossible_dates: 4)

      expect(proposal_type.errors.full_messages.last)
        .to eq("Minimum number of impossible dates can not be greater than maximum number of impossible dates")
    end
  end
end
