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

  describe '#not_closed_date_greater' do
    let(:proposal_type) { create(:proposal_type)}

    context 'whe./spec/models/proposal_type_spec.rbn open_date is nil' do
      it 'expecting' do
        proposal_type.update(open_date: nil)
        response = proposal_type.not_closed_date_greater
        expect(response).to eq(nil)
      end
    end

    context 'when open_date is nil' do
      it 'expecting' do
        proposal_type.update(open_date: Date.today + 10.days)
        response = proposal_type.not_closed_date_greater
        expect(proposal_type.errors.full_messages).to eq(["Open date  2022-12-15 - cannot be greater than Closed Date 2022-12-11", "Open date  2022-12-15 - cannot be greater than Closed Date 2022-12-11"])
      end
    end

    context 'when open_date is nil' do
      it 'expecting' do
        proposal_type.update(open_date: Date.today, closed_date: Date.today)
        response = proposal_type.not_closed_date_greater
        expect(proposal_type.errors.full_messages).to eq(["Open date  2022-12-05 - cannot be same as Closed Date 2022-12-05", "Open date  2022-12-05 - cannot be same as Closed Date 2022-12-05"])
      end
    end
  end

  describe 'max_preferred_greater_than_min_preferred' do
    let(:proposal_type) { create(:proposal_type)}
    it 'expecting' do
      proposal_type.update(min_no_of_preferred_dates: 3)
      response = proposal_type.max_preferred_greater_than_min_preferred
      expect(proposal_type.errors.full_messages).to eq(["Minimum number of preferred dates can not be greater than maximum number of preferred dates", "Minimum number of preferred dates can not be greater than maximum number of preferred dates"])
    end
  end
  describe 'max_preferred_greater_than_min_preferred' do
    let(:proposal_type) { create(:proposal_type)}
    it 'expecting' do
      proposal_type.update(min_no_of_impossible_dates: 4)
      response = proposal_type.max_impossible_greater_than_min_impossible
      expect(proposal_type.errors.full_messages).to eq(["Min no of impossible dates must be less than or equal to 2", "Minimum number of impossible dates can not be greater than maximum number of impossible dates", "Minimum number of impossible dates can not be greater than maximum number of impossible dates"])
    end
  end
end
