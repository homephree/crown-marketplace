require 'rails_helper'

module FacilitiesManagement
  RSpec.describe Lot, type: :model do
    subject(:lots) { described_class.all }

    let(:first_lot) { lots.first }

    it 'loads lots from CSV' do
      expect(lots.count).to eq(3)
    end

    it 'populates attributes of first lot' do
      expect(first_lot.number).to eq('1a')
      expect(first_lot.description).to eq('Total contract value up to £7M')
    end

    describe '#direct_award_possible?' do
      let(:result) { lot.direct_award_possible? }

      context 'when number is 1a' do
        let(:lot) { described_class.find_by(number: '1a') }

        it 'returns truth-y' do
          expect(result).to be_truthy
        end
      end

      context 'when number is not 1a' do
        let(:lot) { described_class.find_by(number: '1b') }

        it 'returns false-y' do
          expect(result).to be_falsey
        end
      end
    end
  end
end
