require 'rails_helper'

RSpec.feature "Locations new", type: :feature do
  let(:person) { create(:person) }
  let(:role) { create(:role, name: 'Staff') }
  let(:user) { create(:user, person: person) }
  let(:location) { create(:location) }
  let(:role_privilege) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "Location", role_id: role.id)
  end

  before do
    role_privilege
    user.roles << role
    login_as(user)
    visit new_location_path
  end

  scenario "there is an empty Name field" do
    expect(find_field('location_name').value).to eq(nil)
  end

  scenario "there is an empty Code field" do
    expect(find_field('location_code').value).to eq(nil)
  end

  scenario "there is an empty City field" do
    expect(find_field('location_city').value).to eq(nil)
  end

  scenario "there is an empty Country field" do
    expect(find_field('location_country').value).to eq(nil)
  end

  scenario "there is an empty Start Date field" do
    expect(find_field('location_start_date').value).to eq(nil)
  end

  scenario "there is an empty End Date field" do
    expect(find_field('location_end_date').value).to eq(nil)
  end

  scenario "there is an empty Exclude Dates field" do
    expect(find_field('location_exclude_dates').value).to eq(nil)
  end

  scenario "updating the form fields create new location" do
    fill_in 'location_name', with: 'New york'
    fill_in 'location_code', with: 'NY'
    fill_in 'location_city', with: 'Buffalo, New York'
    fill_in 'location_country', with: 'United States'
    fill_in 'location_start_date', with: Time.current.to_date
    fill_in 'location_end_date', with: (Time.current + 2.days).to_date
    fill_in 'location_exclude_dates', with: '02/05/2022 to 10/05/2022'
    click_button 'Create New Location'

    # flash messages need to be re-implemented in new theme
    # expect(page).to have_text('Location was successfully updated')
    updated_location = Location.last
    expect(updated_location.name).to eq('New york')
    expect(updated_location.code).to eq('NY')
    expect(updated_location.city).to eq('Buffalo, New York')
    expect(updated_location.country).to eq('United States')
    expect(updated_location.start_date.to_date).to eq(Time.current.to_date)
    expect(updated_location.end_date.to_date).to eq((Time.current + 2.days).to_date)
    expect(updated_location.exclude_dates).to eq('02/05/2022 to 10/05/2022')
  end

  scenario "click back button" do
    expect(page).to have_link(href: locations_path)
  end
end
