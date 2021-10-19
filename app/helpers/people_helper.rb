module PeopleHelper
  def academic_status_options
    academic = [['Graduate Student', 'Graduate Student'],
                ['Post Doctoral', 'Post Doctoral'],
                ['Tenure-Track Faculty', 'Tenure-Track Faculty'],
                ['Tenured Faculty', 'Tenured Faculty'],
                ['Professor Emeritus', 'Professor Emeritus'],
                ['Industry Scientist', 'Industry Scientist'], %w[Other Other]]
    academic.map { |disp, _value| disp }
  end

  def phd_year_options
    phd_year = [%w[N/A]]
    (1951..2021).each do |i|
      phd_year.push(i)
    end
    phd_year.push
  end

  def country_options
    countries = [
      %w[Canada Canada], %w[France France], %w[Germany Germany], %w[Italy Italy],
      ['United Kingdom', 'United Kingdom'],
      ['United States of America', 'United States of America'],
      %w[],
      %w[Afghanistan Afghanistan], ['Åland Islands', 'Åland Islands'], %w[Albania Albania],
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
      %w[Zimbabwe Zimbabwe]
    ]
    countries.map { |disp, _value| disp }
  end

  def country_canada_options
    country_canada = [%w[Alberta Alberta], ['British Columbia', 'British Columbia'], %w[Manitoba Manitoba],
                      %w[Ontario Ontario], ['New Brunswick', 'New Brunswick'],
                      ['Newfoundland and Labrador', 'Newfoundland and Labrador'],
                      ['Northwest Territories', 'Northwest Territories'], ['Nova Scotia', 'Nova Scotia'],
                      %w[Nunavut Nunavut], ['Prince Edward Island', 'Prince Edward Island'],
                      %w[Quebec Quebec], %w[Saskatchewan Saskatchewan], %w[Yukon Yukon]]
    country_canada.map { |disp, _value| disp }
  end

  def country_united_states_of_america_options
    country_united_states_of_america = [%w[Alabama Alabama], %w[Alaska Alaska], %w[Arizona Arizona],
                                        %w[Arkansas Arkansas], %w[California California],
                                        %w[Colorado Colorado], %w[Connecticut Connecticut],
                                        %w[Delaware Delaware], %w[Florida Florida],
                                        %w[Georgia Georgia], %w[Hawaii Hawaii], %w[Idaho Idaho], %w[Illinois Illinois],
                                        %w[Indiana Indiana], %w[Iowa Iowa], %w[Kansas Kansas],
                                        %w[Kentucky Kentucky], %w[Louisiana Louisiana], %w[Maine Maine],
                                        %w[Maryland Maryland], %w[Massachusetts Massachusetts], %w[Michigan Michigan],
                                        %w[Minnesota Minnesota], %w[Mississippi Mississippi],
                                        %w[Missouri Missouri], %w[Montana Montana], %w[Nebraska Nebraska],
                                        %w[Nevada Nevada], ['New Hampshire', 'New Hampshire'],
                                        ['New Jersey', 'New Jersey'], ['New Mexico', 'New Mexico'],
                                        ['New York', 'New York'], ['North Carolina', 'North Carolina'],
                                        ['North Dakota', 'North Dakota'], %w[Ohio Ohio], %w[Oklahoma Oklahoma],
                                        %w[Oregon Oregon], %w[Pennsylvania Pennsylvania],
                                        ['Rhode Island', 'Rhode Island'], ['South Carolina', 'South Carolina'],
                                        ['South Dakota', 'South Dakota'], %w[Tennessee Tennessee], %w[Texas Texas],
                                        %w[Utah Utah], %w[Vermont Vermont], %w[Virginia Virginia],
                                        %w[Washington Washington], ['West Virginia', 'West Virginia'],
                                        %w[Wisconsin Wisconsin], %w[Wyoming Wyoming],
                                        ['District of Columbia', 'District of Columbia'],
                                        ['American Samoa', 'American Samoa'], %w[Guam Guam],
                                        ['Northern Mariana Islands', 'Northern Mariana Islands'],
                                        ['Puerto Rico', 'Puerto Rico'],
                                        ['U.S. Virgin Islands', 'U.S. Virgin Islands']]
    country_united_states_of_america.map { |disp, _value| disp }
  end
end
