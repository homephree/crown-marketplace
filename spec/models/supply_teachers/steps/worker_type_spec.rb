require 'rails_helper'

module SupplyTeachers
  module Steps
    RSpec.describe WorkerType, type: :model do
      subject(:step) { described_class.new(worker_type: 'nominated') }

      let(:model_key) { 'activemodel.errors.models.supply_teachers/steps/worker_type' }

      it { is_expected.to be_valid }

      context 'when worker_type is not valid' do
        before do
          step.worker_type = 'unacceptable-value'
        end

        it { is_expected.not_to be_valid }

        it 'obtains the error message from an I18n translation' do
          step.valid?
          expect(step.errors[:worker_type]).to include(
            I18n.t("#{model_key}.attributes.worker_type.inclusion")
          )
        end
      end
    end
  end
end
