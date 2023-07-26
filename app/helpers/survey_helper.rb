module SurveyHelper
  def citizenship_options
    citizenships = [%w[Afghanistan Afghanistan], ['Åland Islands', 'Åland Islands'], %w[Albania Albania],
                    %w[Algeria Algeria], ['American Samoa', 'American Samoa'], %w[Andorra Andorra],
                    %w[Angola Angola], %w[Anguilla Anguilla], %w[Antarctica Antarctica], %w[Antigua Antigua],
                    %w[Argentina Argentina], %w[Armenia Armenia], %w[Aruba Aruba], %w[Australia Australia],
                    %w[Austria Austria], %w[Azerbaijan Azerbaijan], %w[Bahamas Bahamas], %w[Bahrain Bahrain],
                    %w[Bangladesh Bangladesh], %w[Barbados Barbados], %w[Barbuda Barbuda], %w[Belarus Belarus],
                    %w[Belgium Belgium], %w[Belize Belize], %w[Benin Benin], %w[Bermuda Bermuda],
                    %w[Bhutan Bhutan], %w[Bolivia Bolivia],
                    ['Bosnia and Herzegovina', 'Bosnia and Herzegovina'], %w[Botswana Botswana],
                    ['Bouvet Island', 'Bouvet Island'], %w[Brazil Brazil],
                    ['British Indian Ocean Territory', 'British Indian Ocean Territory'],
                    ['British Virgin Islands', 'British Virgin Islands'],
                    ['Brunei Darussalam', 'Brunei Darussalam'], %w[Bulgaria Bulgaria],
                    ['Burkina Faso', 'Burkina Faso'], %w[Burundi Burundi], ['Cabo Verde', 'Cabo Verde'],
                    %w[Cambodia Cambodia], %w[Cameroon Cameroon], %w[Canada Canada],
                    ['Cayman Islands', 'Cayman Islands'],
                    ['Central African Republic', 'Central African Republic'], %w[Chad Chad], %w[Chile Chile],
                    %w[China China], ['Christmas Island', 'Christmas Island'],
                    ['Cocos (Keeling) Islands', 'Cocos (Keeling) Islands'], %w[Colombia Colombia],
                    %w[Comoros Comoros], ['Congo (Congo-Brazzaville)', 'Congo (Congo-Brazzaville)'],
                    ['Cook Islands', 'Cook Islands'], ['Costa Rica', 'Costa Rica'],
                    ['Côte d’Ivoire', 'Côte d’Ivoire'], %w[Croatia Croatia], %w[Cuba Cuba],
                    %w[Curaçao Curaçao], %w[Cyprus Cyprus],
                    ['Czechia', 'Czechia (Czech Republic)'],
                    ['Democratic Republic of the Congo', 'Democratic Republic of the Congo'],
                    %w[Denmark Denmark], %w[Djibouti Djibouti], %w[Dominica Dominica],
                    ['Dominican Republic', 'Dominican Republic'], %w[Ecuador Ecuador], %w[Egypt Egypt],
                    ['El Salvador', 'El Salvador'], ['Equatorial Guinea', 'Equatorial Guinea'],
                    %w[Eritrea Eritrea], %w[Estonia Estonia],
                    ['Eswatini', 'Eswatini (fmr. "Swaziland")'], %w[Ethiopia Ethiopia],
                    ['Falkland Islands (Malvinas)', 'Falkland Islands (Malvinas)'],
                    ['Faroe Islands', 'Faroe Islands'], %w[Fiji Fiji], %w[Finland Finland],
                    %w[France France], ['French Guiana', 'French Guiana'],
                    ['French Polynesia', 'French Polynesia'],
                    ['French Southern Territories', 'French Southern Territories'], %w[Gabon Gabon],
                    %w[Gambia Gambia], %w[Georgia Georgia], %w[Germany Germany], %w[Ghana Ghana],
                    %w[Gibraltar Gibraltar], %w[Greece Greece], %w[Greenland Greenland],
                    %w[Grenada Grenada], %w[Guadeloupe Guadeloupe], %w[Guam Guam],
                    %w[Guatemala Guatemala], %w[Guernsey Guernsey], %w[Guinea Guinea],
                    %w[Guinea-Bissau Guinea-Bissau], %w[Guyana Guyana], %w[Haiti Haiti],
                    ['Heard Island and McDonald Islands', 'Heard Island and McDonald Islands'],
                    ['Holy See', 'Holy See'], %w[Honduras Honduras], ['Hong Kong', 'Hong Kong'],
                    %w[Hungary Hungary], %w[Iceland Iceland], %w[India India], %w[Indonesia Indonesia],
                    %w[Iran Iran], %w[Iraq Iraq], %w[Ireland Ireland], ['Isle of Man', 'Isle of Man'],
                    %w[Israel Israel], %w[Italy Italy], %w[Jamaica Jamaica], %w[Japan Japan],
                    %w[Jersey Jersey], %w[Jordan Jordan], %w[Kazakhstan Kazakhstan], %w[Kenya Kenya],
                    %w[Kiribati Kiribati], %w[Kuwait Kuwait], %w[Kyrgyzstan Kyrgyzstan],
                    ["Lao People's Democratic Republic", "Lao People's Democratic Republic"],
                    %w[Laos Laos], %w[Latvia Latvia], %w[Lebanon Lebanon], %w[Lesotho Lesotho],
                    %w[Liberia Liberia], %w[Libya Libya], %w[Liechtenstein Liechtenstein],
                    %w[Lithuania Lithuania], %w[Luxembourg Luxembourg], %w[Macao Macao],
                    %w[Madagascar Madagascar], %w[Malawi Malawi], %w[Malaysia Malaysia],
                    %w[Maldives Maldives], %w[Mali Mali], %w[Malta Malta],
                    %w[Marshall Islands Marshall Islands], %w[Martinique Martinique],
                    %w[Mauritania Mauritania], %w[Mauritius Mauritius], %w[Mayotte Mayotte],
                    %w[Mexico Mexico], %w[Micronesia Micronesia], %w[Moldova Moldova],
                    %w[Monaco Monaco], %w[Mongolia Mongolia], %w[Montenegro Montenegro],
                    %w[Montserrat Montserrat], %w[Morocco Morocco], %w[Mozambique Mozambique],
                    ['Myanmar (formerly Burma)', 'Myanmar (formerly Burma)'], %w[Namibia Namibia],
                    %w[Nauru Nauru], %w[Nepal Nepal], %w[Netherlands Netherlands],
                    ['New Caledonia', 'New Caledonia'], ['New Zealand', 'New Zealand'],
                    %w[Nicaragua Nicaragua], %w[Niger Niger], %w[Nigeria Nigeria], %w[Niue Niue],
                    ['Norfolk Island', 'Norfolk Island'], ['North Korea', 'North Korea'],
                    ['North Macedonia', 'North Macedonia'],
                    ['Northern Mariana Islands', 'Northern Mariana Islands'], %w[Norway Norway],
                    %w[Oman Oman], %w[Pakistan Pakistan], %w[Palau Palau],
                    ['Palestine State', 'Palestine State'], %w[Panama Panama],
                    ['Papua New Guinea', 'Papua New Guinea'], %w[Paraguay Paraguay], %w[Peru Peru],
                    %w[Philippines Philippines], %w[Pitcairn Pitcairn], %w[Poland Poland],
                    %w[Portugal Portugal], ['Puerto Rico', 'Puerto Rico'], %w[Qatar Qatar],
                    %w[Réunion Réunion], %w[Romania Romania], %w[Russia Russia], %w[Rwanda Rwanda],
                    ['Saint Barthélemy', 'Saint Barthélemy'], ['Saint Helena', 'Saint Helena'],
                    ['Saint Kitts and Nevis', 'Saint Kitts and Nevis'], ['Saint Lucia', 'Saint Lucia'],
                    ['Saint Vincent and the Grenadines', 'Saint Vincent and the Grenadines'], %w[Samoa Samoa],
                    ['San Marino', 'San Marino'], ['Sao Tome and Principe', 'Sao Tome and Principe'],
                    %w[Sark Sark], ['Saudi Arabia', 'Saudi Arabia'], %w[Senegal Senegal],
                    %w[Serbia Serbia], %w[Seychelles Seychelles], ['Sierra Leone', 'Sierra Leone'],
                    %w[Singapore Singapore], ['Sint Maarten', 'Sint Maarten'], %w[Slovakia Slovakia],
                    %w[Slovenia Slovenia], ['Solomon Islands', 'Solomon Islands'], %w[Somalia Somalia],
                    ['South Africa', 'South Africa'],
                    ['South Georgia and the South Sandwich Islands', 'South Georgia and the South Sandwich Islands'],
                    ['South Korea', 'South Korea'], ['South Sudan', 'South Sudan'], %w[Spain Spain],
                    ['Sri Lanka', 'Sri Lanka'], %w[Sudan Sudan], %w[Suriname Suriname], %w[Sweden Sweden],
                    %w[Switzerland Switzerland], %w[Syria Syria], %w[Tajikistan Tajikistan], %w[Taiwan Taiwan],
                    %w[Tanzania Tanzania], %w[Thailand Thailand], %w[Timor-Leste Timor-Leste], %w[Togo Togo],
                    %w[Tokelau Tokelau], %w[Tonga Tonga], ['Trinidad and Tobago', 'Trinidad and Tobago'],
                    %w[Tunisia Tunisia], %w[Turkey Turkey], %w[Turkmenistan Turkmenistan],
                    ['Turks and Caicos Islands', 'Turks and Caicos Islands'], %w[Tuvalu Tuvalu],
                    %w[Uganda Uganda], %w[Ukraine Ukraine], ['United Arab Emirates', 'United Arab Emirates'],
                    ['United Kingdom', 'United Kingdom'],
                    ['United Republic of Tanzania', 'United Republic of Tanzania'],
                    ['United States Minor Outlying Islands', 'United States Minor Outlying Islands'],
                    ['United States of America', 'United States of America'],
                    %w[Uruguay Uruguay], %w[Uzbekistan Uzbekistan], %w[Vanuatu Vanuatu], %w[Venezuela Venezuela],
                    %w[Vietnam Vietnam], ['Wallis and Futuna Islands', 'Wallis and Futuna Islands'],
                    ['Western Sahara', 'Western Sahara'], %w[Yemen Yemen], %w[Zambia Zambia],
                    %w[Zimbabwe Zimbabwe], %w[Other Other],
                    ['Prefer not to answer', 'Prefer not to answer']]
    citizenships.map { |disp, _value| disp }
  end

  def ethnicity_options
    ethnicity = [%w[Arab Arab], %w[Black Black], %w[Chinese Chinese], %w[Filipino Filipino],
                 ['Indigenous (within North America)', 'Indigenous (within North America)'],
                 %w[Japanese Japanese], %w[Korean Korean], ['Hispanic/Latin American', 'Hispanic/Latin American'],
                 ['South Asian (e.g., Indian, Pakistani, Sri Lankan)',
                  'South Asian (e.g., Indian, Pakistani, Sri Lankan)'],
                 ['Southeast Asian (e.g., Vietnamese, Cambodian, Laotian, Thai)',
                  'Southeast Asian (e.g., Vietnamese, Cambodian, Laotian, Thai)'],
                 ['West Asian (e.g., Iranian, Afghan)', 'West Asian (e.g., Iranian, Afghan)'],
                 %w[White White], %w[Other Other],
                 ['Prefer not to answer (Please note: If you choose this response, none of your other
                  responses to this question will be considered in the data analysis.)'.squish, 'Prefer not to answer (Please note: If you choose this response, none of your other responses to this question will be considered in the data analysis.)']]
    ethnicity.map { |disp, _value| disp }
  end

  def gender_options
    gender = [%w[Woman Woman], %w[Man Man], ['Gender fluid and/or non-binary person',
                                             'Gender fluid and/or non-binary person'], %w[Other Other],
              ['Prefer not to answer', 'Prefer not to answer']]
    gender.map { |disp, _value| disp }
  end

  def indigenous_person_options
    indigenous = [%w[Yes Yes], %w[No No], ['Prefer not to answer', 'Prefer not to answer']]
    indigenous.map { |disp, _value| disp }
  end

  def indigenous_person_yes_options
    indigenous_yes = [
      ['First Nation', 'First Nation'], %w[Métis Métis], %w[Inuit Inuit],
      ['Native American (including Natives of Alaska and Hawaii)',
       'Native American (including Natives of Alaska and Hawaii)'],
      ['Indigenous from outside of what is now known as Canada and the United States',
       'Indigenous from outside of what is now known as Canada and the United States'],
      ['Prefer not to answer', 'Prefer not to answer']
    ]
    indigenous_yes.map { |disp, _value| disp }
  end

  def indigenous_radio_option(results, option)
    results["indigenous_person"] === option ? true : false # rubocop:disable Style/CaseEquality
  end

  def community_radio_option(results, option)
    results["community"] === option ? true : false # rubocop:disable Style/CaseEquality
  end

  def minorities_radio_option(results, option)
    results["minorities"] === option ? true : false # rubocop:disable Style/CaseEquality
  end

  def stem_radio_option(results, option)
    results["stem"] === option ? true : false # rubocop:disable Style/CaseEquality
  end

  def under_represented_radio_option(results, option)
    results["underRepresented"] === option ? true : false # rubocop:disable Style/CaseEquality
  end

  def disability_radio_option(results, option)
    results["disability"] === option ? true : false # rubocop:disable Style/CaseEquality
  end
end
