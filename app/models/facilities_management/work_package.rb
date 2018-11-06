class FacilitiesManagement::WorkPackage
  include StaticRecord

  attr_accessor :code, :name
end

FacilitiesManagement::WorkPackage.load_csv('facilities_management_work_packages.csv')