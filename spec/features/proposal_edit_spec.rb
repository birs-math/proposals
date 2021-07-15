require 'rails_helper'

RSpec.feature "Proposal edit", type: :feature do
  before do
    person = create(:person, :with_proposals)
    @subjects = create_list(:subject, 4)
    @proposal = person.proposals.first
    authenticate_user(person)
    visit edit_proposal_path(@proposal)
  end

  scenario "there is a Title field containing the title" do
    expect(find_field('title').value).to eq(@proposal.title)
  end

  scenario "there is a Type of Meeting field containing the type of meeting" do
    expect(page).to have_text(@proposal.proposal_type.name)
  end

  scenario "there is a Year field containing the year" do
    expect(page).to have_select('year', selected: @proposal.proposal_type.year.split(',').last)
  end

  # scenario "there is a Subject Area field containing the subject area" do
  #   @proposal.update(subject: @subjects.first)
  #   expect(page).to have_select('subject_id', selected: @subjects.first.title)
  # end
end
