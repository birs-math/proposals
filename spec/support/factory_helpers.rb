# ./spec/support/factory_helpers.rb

# methods to help in factories
module FactoryHelpers
  def set_valid_country
    country = Faker::Address.country
    country = Faker::Address.country while Country.find_by_name(country).nil?
    country
  end
end
