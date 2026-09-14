class FixDemographicDataArrayFields < ActiveRecord::Migration[6.1]
  ARRAY_FIELDS = %w[citizenships ethnicity indigenous_person_yes].freeze

  def up
    DemographicData.find_each do |record|
      result = record.result
      changed = false

      ARRAY_FIELDS.each do |field|
        next unless result.key?(field)
        if result[field].is_a?(String)
          result[field] = [result[field]]
          changed = true
        end
      end

      record.update_columns(result: result) if changed
    end
  end
end
