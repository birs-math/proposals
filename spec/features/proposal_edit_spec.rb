require 'rails_helper'

RSpec.feature "Proposal edit", type: :feature do
  let(:person) { create(:person, :with_proposals) }
  let(:proposal) { person.proposals.first }

  before do
    authenticate_user(person)
    expect(person.user.lead_organizer?(proposal)).to be_truthy
    visit edit_proposal_path(proposal)
  end

  scenario "there is a Title field containing the title" do
    expect(current_path).to eq(edit_proposal_path(proposal))
    expect(find_field('title').value).to eq(proposal.title)
  end

  scenario "there is a Type of Meeting field containing the type of meeting" do
    expect(page).to have_text(proposal.proposal_type.name)
  end

  scenario "there is a Year field containing the year" do
    expect(page).to have_select('year', options: [''] + proposal.proposal_type.year.split(','))
  end

  context "Subject Areas" do
    let(:subjects) { create_list(:subject, 4, subject_category_id: subject_category.id) }
    let(:subject_category) { create(:subject_category) }

    before do
      proposal.update(subject: subjects.first)

      visit edit_proposal_path(proposal)
    end

    scenario "there is a Subject Area field containing the subject area" do
      expect(page).to have_select('subject_id', selected: subjects.first.title)
    end
  end

  def shows_person_info(person)
    expect(page).to have_text("First Name:")
    expect(page).to have_text(person.firstname)
    expect(page).to have_text("Last Name:")
    expect(page).to have_text(person.lastname)
    expect(page).to have_text("Email:")
    expect(page).to have_text(person.email)
  end

  scenario "the Lead Organizer's information is shown" do
    shows_person_info(proposal.lead_organizer)
  end

  scenario "the Suporting Organizers' information is shown" do
    create(:invite, proposal: proposal, status: 'confirmed', invited_as: 'Organizer')
    proposal.reload

    expect(proposal.supporting_organizer_invites).not_to be_empty

    visit edit_proposal_path(proposal)

    proposal.supporting_organizer_invites.each do |invite|
      shows_person_info(invite.person)
    end
  end

  scenario "there is a form for uploading files" do
    expect(page.body).to have_text('Supplementary Files')

    within("form#submit_proposal") do
      expect(have_field('#file-upload')).to be_truthy
    end
  end

  describe 'inviting members and organizers' do
    before do
      proposal.update_attribute(:title, title)
      Invite.delete_all

      visit edit_proposal_path(proposal)
    end

    context 'when proposal title is not present' do
      let(:title) { nil }

      it 'has disabled invite organizers buttons' do
        expect(page).to have_button('Invite Organizer(s)', disabled: true)
        expect(page).to have_button('Click here to send out additional organizer invitation', disabled: true)
      end

      it 'has disabled add participants buttons' do
        expect(page).to have_button('Invite Participant(s)', disabled: true)
        expect(page).to have_button(I18n.t('proposals.form.new_participants_invite'), disabled: true)
      end
    end

    context 'when proposal title is present' do
      let(:title) { 'New title' }

      it 'has invite organizers buttons' do
        expect(page).to have_button('Invite Organizer(s)', disabled: false)
        expect(page).to have_button('Click here to send out additional organizer invitation', disabled: false)
      end

      it 'has add participants buttons' do
        expect(page).to have_button('Invite Participant(s)', disabled: false)
        expect(page).to have_button(I18n.t('proposals.form.new_participants_invite'), disabled: false)
      end
    end
  end
end
