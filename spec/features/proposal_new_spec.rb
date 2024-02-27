require 'rails_helper'

RSpec.describe "Proposal New", type: :feature do
  before do
    proposal_type = create(:proposal_type)
    create(:proposal_form, status: :active, proposal_type: proposal_type)
    authenticate_user
    visit new_proposal_path
  end

  scenario "there is a list of all proposal types" do
    ProposalType.all.each do |proposal_type|
      expect(page).to have_text(proposal_type.name)
    end
  end

  # TODO: fix after adding selenium webdriver to capybara
  pending "creating a new proposal " do
    find('input[name="commit"]').click
    expect(Proposal.count).to eq(1)
    expect(page).to have_current_path(edit_proposal_path(Proposal.last))
  end
end
