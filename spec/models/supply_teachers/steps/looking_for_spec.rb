require 'rails_helper'

module SupplyTeachers
  module Steps
    RSpec.describe LookingFor, type: :model do
      subject(:step) { described_class.new(looking_for: 'worker') }

      let(:model_key) { 'activemodel.errors.models.supply_teachers/steps/looking_for' }

      it { is_expected.to be_valid }

      context 'when looking_for is not valid' do
        before do
          step.looking_for = 'unacceptable-value'
        end

        it { is_expected.not_to be_valid }

        it 'obtains the error message from an I18n translation' do
          step.valid?
          expect(step.errors[:looking_for]).to include(
            I18n.t("#{model_key}.attributes.looking_for.inclusion")
          )
        end
      end
    end
  end
end
