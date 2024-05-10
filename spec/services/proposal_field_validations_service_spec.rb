require 'rails_helper'

RSpec.describe ProposalFieldValidationsService, type: :service do
  let(:proposal) { create(:proposal) }
  let(:proposal_field) { create(:proposal_field) }
  let(:answer) { create(:answer, proposal: proposal, proposal_field: proposal_field) }
  let(:service) { ProposalFieldValidationsService.new(proposal_field, proposal) }

  describe '#validations' do
    context 'when validation type is mandatory' do
      let!(:validation) { create(:validation, validation_type: 'mandatory', proposal_field: proposal_field) }

      context 'when answer is blank' do
        before do
          allow(Answer).to receive(:find_by).and_return(nil)
          service.validations
        end

        it 'adds error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to include(service.error_message(validation))
        end
      end

      context 'when answer is not blank' do
        before do
          allow(Answer).to receive(:find_by).and_return(answer)
          service.validations
        end

        it 'does not add error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to be_empty
        end
      end
    end

    context 'when validation type is less than (integer matcher)' do
      let!(:validation) do
        create(:validation, validation_type: 'less than (integer matcher)', proposal_field: proposal_field, value: 5)
      end

      context 'when answer is less than validation value' do
        let(:answer) { create(:answer, proposal: proposal, proposal_field: proposal_field, answer: '4') }

        before do
          allow(Answer).to receive(:find_by).and_return(answer)
          service.validations
        end

        it 'does not add error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to be_empty
        end
      end

      context 'when answer is not less than validation value' do
        let(:answer) { create(:answer, proposal: proposal, proposal_field: proposal_field, answer: '6') }

        before do
          allow(Answer).to receive(:find_by).and_return(answer)
          service.validations
        end

        it 'adds error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to include(service.error_message(validation))
        end
      end
    end

    context 'when validation type is less than (float matcher)' do
      let!(:validation) do
        create(:validation, validation_type: 'less than (float matcher)', proposal_field: proposal_field, value: 5.0)
      end

      context 'when answer is less than validation value' do
        let(:answer) { create(:answer, proposal: proposal, proposal_field: proposal_field, answer: '4.0') }

        before do
          allow(Answer).to receive(:find_by).and_return(answer)
          service.validations
        end

        it 'does not add error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to be_empty
        end
      end

      context 'when answer is not less than validation value' do
        let(:answer) { create(:answer, proposal: proposal, proposal_field: proposal_field, answer: '6.0') }

        before do
          allow(Answer).to receive(:find_by).and_return(answer)
          service.validations
        end

        it 'adds error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to include(service.error_message(validation))
        end
      end
    end

    context 'when validation type is greater than (integer matcher)' do
      let!(:validation) do
        create(:validation, validation_type: 'greater than (integer matcher)', proposal_field: proposal_field, value: 5)
      end

      context 'when answer is greater than validation value' do
        let(:answer) { create(:answer, proposal: proposal, proposal_field: proposal_field, answer: '6') }

        before do
          allow(Answer).to receive(:find_by).and_return(answer)
          service.validations
        end

        it 'does not add error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to be_empty
        end
      end

      context 'when answer is not greater than validation value' do
        let(:answer) { create(:answer, proposal: proposal, proposal_field: proposal_field, answer: '4') }

        before do
          allow(Answer).to receive(:find_by).and_return(answer)
          service.validations
        end

        it 'adds error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to include(service.error_message(validation))
        end
      end
    end

    context 'when validation type is greater than (float matcher)' do
      let!(:validation) do
        create(:validation, validation_type: 'greater than (float matcher)', proposal_field: proposal_field, value: 5.0)
      end

      context 'when answer is greater than validation value' do
        let(:answer) { create(:answer, proposal: proposal, proposal_field: proposal_field, answer: '6.0') }

        before do
          allow(Answer).to receive(:find_by).and_return(answer)
          service.validations
        end

        it 'does not add error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to be_empty
        end
      end

      context 'when answer is not greater than validation value' do
        let(:answer) { create(:answer, proposal: proposal, proposal_field: proposal_field, answer: '4.0') }

        before do
          allow(Answer).to receive(:find_by).and_return(answer)
          service.validations
        end

        it 'adds error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to include(service.error_message(validation))
        end
      end
    end

    context 'when validation type is equal (string matcher)' do
      let!(:validation) do
        create(:validation, validation_type: 'equal (string matcher)', proposal_field: proposal_field, value: 'string')
      end

      context 'when answer is equal to validation value' do
        let(:answer) { create(:answer, proposal: proposal, proposal_field: proposal_field, answer: 'string') }

        before do
          allow(Answer).to receive(:find_by).and_return(answer)
          service.validations
        end

        it 'does not add error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to be_empty
        end
      end

      context 'when answer is not equal to validation value' do
        let(:answer) { create(:answer, proposal: proposal, proposal_field: proposal_field, answer: 'different') }

        before do
          allow(Answer).to receive(:find_by).and_return(answer)
          service.validations
        end

        it 'adds error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to include(service.error_message(validation))
        end
      end
    end

    context 'when validation type is equal (integer matcher)' do
      let!(:validation) do
        create(:validation, validation_type: 'equal (integer matcher)', proposal_field: proposal_field, value: 5)
      end

      context 'when answer is equal to validation value' do
        let(:answer) { create(:answer, proposal: proposal, proposal_field: proposal_field, answer: '5') }

        before do
          allow(Answer).to receive(:find_by).and_return(answer)
          service.validations
        end

        it 'does not add error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to be_empty
        end
      end

      context 'when answer is not equal to validation value' do
        let(:answer) { create(:answer, proposal: proposal, proposal_field: proposal_field, answer: '6') }

        before do
          allow(Answer).to receive(:find_by).and_return(answer)
          service.validations
        end

        it 'adds error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to include(service.error_message(validation))
        end
      end
    end

    context 'when validation type is equal (float matcher)' do
      let!(:validation) do
        create(:validation, validation_type: 'equal (float matcher)', proposal_field: proposal_field, value: 5.0)
      end

      context 'when answer is equal to validation value' do
        let(:answer) { create(:answer, proposal: proposal, proposal_field: proposal_field, answer: '5.0') }

        before do
          allow(Answer).to receive(:find_by).and_return(answer)
          service.validations
        end

        it 'does not add error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to be_empty
        end
      end

      context 'when answer is not equal to validation value' do
        let(:answer) { create(:answer, proposal: proposal, proposal_field: proposal_field, answer: '6.0') }

        before do
          allow(Answer).to receive(:find_by).and_return(answer)
          service.validations
        end

        it 'adds error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to include(service.error_message(validation))
        end
      end
    end

    context 'when validation type is words limit' do
      let!(:validation) do
        create(:validation, validation_type: 'words limit', proposal_field: proposal_field, value: 4)
      end

      context 'when answer has less words than validation value' do
        let(:answer) do
          create(:answer, proposal: proposal, proposal_field: proposal_field, answer: 'word word word word')
        end

        before do
          allow(Answer).to receive(:find_by).and_return(answer)
          service.validations
        end

        it 'does not add error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to be_empty
        end
      end

      context 'when answer has more words than validation value' do
        let(:answer) do
          create(:answer, proposal: proposal, proposal_field: proposal_field, answer: 'word word word word word')
        end

        before do
          allow(Answer).to receive(:find_by).and_return(answer)
          service.validations
        end

        it 'adds error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to include(service.error_message(validation))
        end
      end
    end

    context 'when validation type is 5-day workshop preferred/Impossible dates' do
      let!(:validation) do
        create(
          :validation,
          validation_type: '5-day workshop preferred/Impossible dates',
          proposal_field: proposal_field
        )
      end

      context 'when answer is nil' do
        let(:answer) { nil }

        before do
          allow(Answer).to receive(:find_by).and_return(nil)
          service.validations
        end

        it 'adds error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to include(
            service.date_error_message(
              validation,
              "You have to choose atleast #{proposal.proposal_type.min_no_of_preferred_dates} preferred dates"
            )
          )
          expect(service.instance_variable_get(:@errors)).to include(
            service.date_error_message(
              validation,
              "You have to choose atleast #{proposal.proposal_type.min_no_of_impossible_dates} impossible dates"
            )
          )
        end
      end

      context 'when answer is not nil' do
        let(:answer) do
          create(:answer, proposal: proposal, proposal_field: proposal_field, answer: '["date1", "date1"]')
        end

        before do
          allow(Answer).to receive(:find_by).and_return(answer)
          service.validations
        end

        it 'adds error message to @errors' do
          expect(service.instance_variable_get(:@errors)).to include(
            service.date_error_message(validation, "You can't select the same date twice")
          )
        end
      end
    end
  end
end
