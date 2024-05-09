require 'rails_helper'

RSpec.describe ProposalFieldValidationsService, type: :service do
  let(:proposal) { create(:proposal) }
  let(:proposal_field) { create(:proposal_field) }
  let(:value) { nil }
  let(:service) { ProposalFieldValidationsService.new(proposal_field, proposal, value) }

  describe '#validations' do
    context 'when validation type is mandatory' do
      let!(:validation) { create(:validation, validation_type: 'mandatory', proposal_field: proposal_field) }

      context 'when value is blank' do
        before do
          service.validations
        end

        it 'adds error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to include(service.error_message(validation))
        end
      end

      context 'when value is not blank' do
        let(:value) { 'answer' }
        before do
          service.validations
        end

        it 'does not add error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to be_empty
        end
      end
    end

    context 'when validation type is less than (integer matcher)' do
      let!(:validation) { create(:validation, validation_type: 'less than (integer matcher)', proposal_field: proposal_field, value: 5) }

      context 'when value is less than validation value' do
        let(:value) { '4' }

        before do
          service.validations
        end

        it 'does not add error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to be_empty
        end
      end

      context 'when value is not less than validation value' do
        let(:value) { '6' }

        before do
          service.validations
        end

        it 'adds error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to include(service.error_message(validation))
        end
      end
    end

    context 'when validation type is less than (float matcher)' do
      let!(:validation) { create(:validation, validation_type: 'less than (float matcher)', proposal_field: proposal_field, value: 5.0) }

      context 'when value is less than validation value' do
        let(:value) { '4.0' }

        before do
          service.validations
        end

        it 'does not add error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to be_empty
        end
      end

      context 'when value is not less than validation value' do
        let(:value) { '6.0' }

        before do
          service.validations
        end

        it 'adds error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to include(service.error_message(validation))
        end
      end
    end

    context 'when validation type is greater than (integer matcher)' do
      let!(:validation) { create(:validation, validation_type: 'greater than (integer matcher)', proposal_field: proposal_field, value: 5) }

      context 'when value is greater than validation value' do
        let(:value) { '6' }

        before do
          service.validations
        end

        it 'does not add error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to be_empty
        end
      end

      context 'when value is not greater than validation value' do
        let(:value) { '4' }

        before do
          service.validations
        end

        it 'adds error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to include(service.error_message(validation))
        end
      end
    end

    context 'when validation type is greater than (float matcher)' do
      let!(:validation) { create(:validation, validation_type: 'greater than (float matcher)', proposal_field: proposal_field, value: 5.0) }

      context 'when value is greater than validation value' do
        let(:value) { '6.0' }

        before do
          service.validations
        end

        it 'does not add error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to be_empty
        end
      end

      context 'when value is not greater than validation value' do
        let(:value) { '4.0' }

        before do
          service.validations
        end

        it 'adds error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to include(service.error_message(validation))
        end
      end
    end

    context 'when validation type is equal (string matcher)' do
      let!(:validation) { create(:validation, validation_type: 'equal (string matcher)', proposal_field: proposal_field, value: 'string') }

      context 'when value is equal to validation value' do
        let(:value) { 'string' }

        before do
          service.validations
        end

        it 'does not add error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to be_empty
        end
      end

      context 'when value is not equal to validation value' do
        let(:value) { 'not string' }

        before do
          service.validations
        end

        it 'adds error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to include(service.error_message(validation))
        end
      end
    end

    context 'when validation type is equal (integer matcher)' do
      let!(:validation) { create(:validation, validation_type: 'equal (integer matcher)', proposal_field: proposal_field, value: 5) }

      context 'when value is equal to validation value' do
        let(:value) { '5' }

        before do
          service.validations
        end

        it 'does not add error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to be_empty
        end
      end

      context 'when value is not equal to validation value' do
        let(:value) { '6' }

        before do
          service.validations
        end

        it 'adds error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to include(service.error_message(validation))
        end
      end
    end

    context 'when validation type is equal (float matcher)' do
      let!(:validation) { create(:validation, validation_type: 'equal (float matcher)', proposal_field: proposal_field, value: 5.0) }

      context 'when value is equal to validation value' do
        let(:value) { '5.0' }

        before do
          service.validations
        end

        it 'does not add error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to be_empty
        end
      end

      context 'when value is not equal to validation value' do
        let(:value) { '6.0' }

        before do
          service.validations
        end

        it 'adds error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to include(service.error_message(validation))
        end
      end
    end

    context 'when validation type is words limit' do
      let!(:validation) { create(:validation, validation_type: 'words limit', proposal_field: proposal_field, value: 4) }

      context 'when value has less words than validation value' do
        let(:value) { 'word word word' }

        before do
          service.validations
        end

        it 'does not add error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to be_empty
        end
      end

      context 'when value has more words than validation value' do
        let(:value) { 'word word word word word' }

        before do
          service.validations
        end

        it 'adds error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to include(service.error_message(validation))
        end
      end
    end

    context 'when validation type is 5-day workshop preferred/Impossible dates' do
      let!(:validation) { create(:validation, validation_type: '5-day workshop preferred/Impossible dates', proposal_field: proposal_field) }

      context 'when value is nil' do
        let(:value) { nil }

        before do
          service.validations
        end

        it 'adds error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to include("You have to choose atleast #{proposal.proposal_type.min_no_of_preferred_dates} preferred dates")
          expect(service.instance_variable_get(:@errors)).to include("You have to choose atleast #{proposal.proposal_type.min_no_of_impossible_dates} impossible dates")
        end
      end

      context 'when value is not nil' do
        let(:value) { '["date1", "date1"]' }

        before do
          service.validations
        end

        it 'adds error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to include("You can't select the same date twice")
        end
      end
    end
  end
end
