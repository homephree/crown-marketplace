module SupplyTeachers
  class Upload
    def self.create!(suppliers)
      error = all_or_none(Supplier) do
        Supplier.destroy_all

        suppliers.map do |supplier_data|
          create_supplier!(supplier_data)
        end
      end
      raise error if error
    end

    def self.all_or_none(transaction_class)
      error = nil
      transaction_class.transaction do
        yield
      rescue ActiveRecord::RecordInvalid => e
        error = e
        raise ActiveRecord::Rollback
      end
      error
    end

    def self.create_supplier!(data)
      s = Supplier.create!(
        id: data['supplier_id'],
        name: data['supplier_name']
      )
      branches = data.fetch('branches', [])
      branches.each do |branch|
        contact_name = branch.dig('contacts', 0, 'name')
        contact_email = branch.dig('contacts', 0, 'email')
        s.branches.create!(
          name: branch['branch_name'],
          town: branch['town'],
          postcode: branch['postcode'],
          location: Geocoding.point(
            latitude: branch['lat'],
            longitude: branch['lon']
          ),
          telephone_number: branch['telephone'],
          contact_name: contact_name,
          contact_email: contact_email
        )
      end

      rates = data.fetch('pricing', [])
      create_supplier_rates!(s, 1, rates)

      master_vendor_rates = data.fetch('master_vendor_pricing', [])
      create_supplier_rates!(s, 2, master_vendor_rates)

      neutral_vendor_rates = data.fetch('neutral_vendor_pricing', [])
      create_supplier_rates!(s, 3, neutral_vendor_rates)
    end

    def self.create_supplier_rates!(supplier, lot_number, rates)
      rates.each do |rate_data|
        rate = supplier.rates.build(
          lot_number: lot_number,
          job_type: rate_data['job_type'],
          term: rate_data['term']
        )
        if rate.daily_fee?
          rate.daily_fee = rate_data['fee']
        else
          rate.mark_up = rate_data['fee'].to_f
        end
        rate.save!
      end
    end
  end
end
