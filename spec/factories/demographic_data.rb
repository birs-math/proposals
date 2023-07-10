FactoryBot.define do
  factory :demographic_data do
    person { association :person }
    result do
      {
        'stem' => %w[Yes No].sample,
        'gender' => %w[Man Woman Other].sample,
        'gender_other' => 'Undefined',
        'community' => %w[Yes No].sample,
        'ethnicity' => %w[White Black Brown Green].sample,
        'ethnicity_other' => '',
        'disability' => %w[Yes No].sample,
        'minorities' => %w[Yes No].sample,
        'citizenships' => %w[Austria Canada France Italy Japan Pakistan].sample,
        'citizenships_other' => '',
        'underRepresented' => %w[Yes No].sample,
        'indigenous_person' => 'Yes',
        'academic_status' => 'Software Engineer',
        'indigenous_person_yes' => [['First Nation', 'First Nation'],
                                    %w[Métis Métis], %w[Inuit Inuit]].sample
      }
    end
    created_at { }
    updated_at { }
  end
end
