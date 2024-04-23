require 'rails_helper'

RSpec.feature "Proposal Type new", type: :feature do
  before do
    create_list(:location, 4)
    visit new_proposal_type_path
  end

  scenario "there is an empty proposal_type_name field" do
    expect(find_field('proposal_type_name').value).to eq(nil)
  end

  scenario "there is a list of all locations" do
    Location.all.each do |location|
      expect(page).to have_text(location.name)
    end
  end

  scenario "click on back button" do
    expect(page).to have_link(href: proposal_types_path)
  end

  scenario "updating the form fields create new Proposal Type" do
    fill_in 'proposal_type_name', with: 'Focussed Research Group'
    fill_in 'proposal_type_year', with: Date.current.year
    fill_in 'proposal_type_co_organizer', with: 2
    fill_in 'proposal_type_participant', with: 3
    fill_in 'proposal_type_code', with: '2021xx2'
    fill_in 'proposal_type_open_date', with: Date.current
    fill_in 'proposal_type_closed_date', with: Date.current + 1.week
    fill_in 'proposal_type_max_no_of_preferred_dates', with: 2
    fill_in 'proposal_type_min_no_of_preferred_dates', with: 2
    fill_in 'proposal_type_max_no_of_impossible_dates', with: 2
    fill_in 'proposal_type_min_no_of_impossible_dates', with: 2
    fill_in 'proposal_type_organizer_description', with: 'A long text passage which describes organizers'
    fill_in 'proposal_type_participant_description', with: 'A long text paragraph which describes participants'
    fill_in 'proposal_type_capacity', with: 42
    select Location.first.name
    click_button 'Create Proposal Type'
    updated_proposal_type = ProposalType.last
    expect(updated_proposal_type.name).to eq('Focussed Research Group')
    expect(updated_proposal_type.locations.first.name).to eq(Location.first.name)
  end
end
