class AddAccreditationBodyToSuppliers < ActiveRecord::Migration[5.2]
  def change
    add_column :suppliers, :accreditation_body, :text
  end
end
