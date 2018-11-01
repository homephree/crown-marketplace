require 'rails_helper'

RSpec.describe FacilitiesManagementUpload, type: :model do
  describe 'create' do
    let(:supplier_name) { Faker::Company.unique.name }
    let(:supplier_id) { SecureRandom.uuid }
    let(:contact_name) { Faker::Name.unique.name }
    let(:contact_email) { Faker::Internet.unique.email }
    let(:telephone_number) { Faker::PhoneNumber.unique.phone_number }

    let(:lots) { [] }

    let(:suppliers) do
      [
        {
          'supplier_name' => supplier_name,
          'supplier_id' => supplier_id,
          'contact_name' => contact_name,
          'contact_email' => contact_email,
          'contact_phone' => telephone_number,
          'lots' => lots
        }
      ]
    end

    context 'when supplier list is empty' do
      let(:suppliers) { [] }

      it 'does not create any suppliers' do
        expect do
          described_class.create!(suppliers)
        end.not_to change(FacilitiesManagementSupplier, :count)
      end
    end

    context 'when supplier does not exist' do
      it 'creates supplier' do
        expect do
          described_class.create!(suppliers)
        end.to change(FacilitiesManagementSupplier, :count).by(1)
      end

      it 'assigns ID to supplier' do
        described_class.create!(suppliers)

        supplier = FacilitiesManagementSupplier.last
        expect(supplier.id).to eq(supplier_id)
      end

      it 'assigns attributes to supplier' do
        described_class.create!(suppliers)

        supplier = FacilitiesManagementSupplier.last
        expect(supplier.name).to eq(supplier_name)
      end

      it 'assigns contact-related attributes to supplier' do
        described_class.create!(suppliers)

        supplier = FacilitiesManagementSupplier.last
        expect(supplier.contact_name).to eq(contact_name)
        expect(supplier.contact_email).to eq(contact_email)
        expect(supplier.telephone_number).to eq(telephone_number)
      end

      context 'and supplier has lots with regions' do
        let(:lots) do
          [
            {
              'lot_number' => '1a',
              'regions' => %w[UKC1 UKC2]
            },
            {
              'lot_number' => '1b',
              'regions' => %w[UKD1]
            },
          ]
        end

        let(:supplier) { FacilitiesManagementSupplier.last }

        let(:regional_availabilities) do
          supplier.regional_availabilities.order(:lot_number, :region_code)
        end

        it 'creates regional availabilities associated with supplier' do
          expect do
            described_class.create!(suppliers)
          end.to change(FacilitiesManagementRegionalAvailability, :count).by(3)
        end

        it 'assigns attributes to first regional availability' do
          described_class.create!(suppliers)

          availability = regional_availabilities.first
          expect(availability.lot_number).to eq('1a')
          expect(availability.region_code).to eq('UKC1')
        end

        it 'assigns attributes to second regional availability' do
          described_class.create!(suppliers)

          availability = regional_availabilities.second
          expect(availability.lot_number).to eq('1a')
          expect(availability.region_code).to eq('UKC2')
        end

        it 'assigns attributes to third regional availability' do
          described_class.create!(suppliers)

          availability = regional_availabilities.third
          expect(availability.lot_number).to eq('1b')
          expect(availability.region_code).to eq('UKD1')
        end
      end
    end

    context 'when suppliers already exist' do
      let!(:first_supplier) { create(:facilities_management_supplier) }
      let!(:second_supplier) { create(:facilities_management_supplier) }

      it 'destroys all existing suppliers' do
        described_class.create!(suppliers)

        expect(FacilitiesManagementSupplier.find_by(id: first_supplier.id)).to be_nil
        expect(FacilitiesManagementSupplier.find_by(id: second_supplier.id)).to be_nil
      end

      context 'and data for one supplier is invalid' do
        let(:suppliers) do
          [
            {
              'supplier_name' => '',
              'contact_name' => '',
              'contact_email' => '',
              'contact_phone' => '',
            }
          ]
        end

        it 'leaves existing data intact' do
          ignoring_exception(ActiveRecord::RecordInvalid) do
            described_class.create!(suppliers)
          end

          expect(FacilitiesManagementSupplier.find_by(id: first_supplier.id)).to eq(first_supplier)
          expect(FacilitiesManagementSupplier.find_by(id: second_supplier.id)).to eq(second_supplier)
        end
      end
    end

    context 'when data for one supplier is invalid' do
      let(:suppliers) do
        [
          {
            'supplier_name' => supplier_name,
            'contact_name' => contact_name,
            'contact_email' => contact_email,
            'contact_phone' => telephone_number,
          },
          {
            'supplier_name' => '',
            'contact_name' => '',
            'contact_phone' => '',
          }
        ]
      end

      it 'raises ActiveRecord::RecordInvalid exception' do
        expect do
          described_class.create!(suppliers)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'does not create any suppliers' do
        expect do
          ignoring_exception(ActiveRecord::RecordInvalid) do
            described_class.create!(suppliers)
          end
        end.not_to change(FacilitiesManagementSupplier, :count)
      end
    end

    context 'when data for one lot is invalid' do
      let(:lots) do
        [
          {
            'lot_number' => '1a',
            'regions' => %w[UKC1 UKC2]
          },
          {
            'lot_number' => '',
            'regions' => %w[UKD1]
          },
        ]
      end

      it 'raises ActiveRecord::RecordInvalid exception' do
        expect do
          described_class.create!(suppliers)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'does not create any suppliers' do
        expect do
          ignoring_exception(ActiveRecord::RecordInvalid) do
            described_class.create!(suppliers)
          end
        end.not_to change(FacilitiesManagementSupplier, :count)
      end
    end

    context 'when data for one region is invalid' do
      let(:lots) do
        [
          {
            'lot_number' => '1a',
            'regions' => %w[UKC1 UKC2]
          },
          {
            'lot_number' => '1b',
            'regions' => ['']
          },
        ]
      end

      it 'raises ActiveRecord::RecordInvalid exception' do
        expect do
          described_class.create!(suppliers)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'does not create any suppliers' do
        expect do
          ignoring_exception(ActiveRecord::RecordInvalid) do
            described_class.create!(suppliers)
          end
        end.not_to change(FacilitiesManagementSupplier, :count)
      end
    end
  end

  private

  def ignoring_exception(klass)
    yield
  rescue klass
    nil
  end
end