class DemographicData < ApplicationRecord
  belongs_to :person

  ARRAY_FIELDS = %w[citizenships ethnicity indigenous_person_yes].freeze

  def result
    raw = super
    raw.merge(raw.slice(*ARRAY_FIELDS).transform_values { |v| Array(v) })
  end
end
