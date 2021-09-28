require 'rails_helper'

RSpec.describe 'EditFlowService' do
  let(:subject_category) { create(:subject_category) }
  let(:subject) { create(:subject, subject_category_id: subject_category.id) }
  let(:ams_subject) do
    create(:ams_subject,
           subject_category_ids: subject_category.id,
           subject_id: subject.id,
           title: '123: This is an AMS Subject')
  end

  before do
    @proposal = create(:proposal, :with_organizers, subject: subject)
    subject1 = create(:proposal_ams_subject, proposal: @proposal,
                      ams_subject: ams_subject)
    subject2 = create(:proposal_ams_subject, proposal: @proposal,
                      ams_subject: ams_subject)
    @proposal.proposal_ams_subjects << subject1
    @proposal.proposal_ams_subjects << subject2
    @EFS = EditFlowService.new(@proposal)
    update_organizers
  end

  def update_organizers
    # ensure country exists in the `Country` database
    countries = %w[Canada Mexico Brazil India Japan Sweden Denmark Ukraine]
    @proposal.lead_organizer.update_columns(country: countries.sample)

    # invite.person info is getting blanked out with invite creation
    @proposal.invites.where(invited_as: 'Organizer').each do |invite|
      person = invite.person
      person.country = countries.sample
      person.affiliation = Faker::University.name
      person.skip_person_validation = true
      person.save!
    end
  end

  it 'has supporting organizers with countries' do
    @proposal.invites.where(invited_as: 'Organizer').each do |invite|
      expect(invite.person.country).not_to be_blank
    end
  end

  it 'accepts a proposal' do
    expect(@EFS.class).to eq(EditFlowService)
  end

  it "assigns the lead organizer's country code" do
    country = @proposal.lead_organizer.country
    code = Country.find_country_by_name(country).alpha2
    expect(@EFS.proposal_country.alpha2).to eq(code)
  end

  it '.ams_subject_code' do
    # rspec factory subjects setup needs revision!
    expect(@EFS.ams_subject_code(:first)).to eq('123-XX')
  end

  context '.proposal_country' do
    it 'returns a Country object for the Lead Organizer' do
      expect(@EFS.proposal_country).to be_a(Country)
      country = Country.find_country_by_name(@proposal.lead_organizer.country)
      expect(@EFS.proposal_country).to eq(country)
    end

    it 'raises a RunTime error if organizer has no country' do
      @proposal.lead_organizer.update_columns(country: nil)

      expect { @EFS.proposal_country }.to raise_error(RuntimeError)

      @proposal.lead_organizer.update_columns(country: 'France')
    end
  end

  context '.organizer_country' do
    before do
      @org_invite = @proposal.invites.first
    end

    it 'accepts an invite and returns a Country object' do
      org_country = @EFS.organizer_country(@org_invite)
      expect(org_country).to be_a(Country)
      expect(org_country.name).to eq(@org_invite.person.country)
    end

    it 'raises a RunTime error if an unknown country is given' do
      person = @org_invite.person
      person.update_columns(country: 'September')

      expect { @EFS.organizer_country(@org_invite) }.to raise_error(RuntimeError)
      person.update_columns(country: 'Italy')
    end
  end

  it ".supporting_organizers" do
    organizers = @EFS.supporting_organizers
    expect(organizers.count).to eq(3)
    expect(organizers.first.class).to eq(Array)

    first_org = @proposal.invites.first.person
    country_code = Country.find_country_by_name(first_org.country).alpha2
    supporting_organizer1 = [first_org, country_code]
    expect(organizers.first).to eq(supporting_organizer1)
  end

  it ".co_authors" do
    expect(@EFS.co_authors).not_to be_empty
  end

  context ".query" do
    before do
      update_organizers
      @result = @EFS.query
      expect(@result).not_to be_empty
      expect(@result.class).to eq(String)
    end

    it 'contains proposal subject, title, lead organizer info' do
      expect(@result).to include(%(code: "#{@proposal.subject.code}"))
      expect(@result).to include(%(title: "#{@proposal.code}: #{@proposal.title}"))
      lead_org = @proposal.lead_organizer
      expect(@result).to include(%(address: "#{lead_org.email}"))
      expect(@result).to include(%(nameFull: "#{lead_org.fullname}"))
      expect(@result).to include(%(nameGiven: "#{lead_org.firstname}"))
      expect(@result).to include(%(nameSurname: "#{lead_org.lastname}"))
      expect(@result).to include(%(name: "#{lead_org.affiliation}"))
    end

    it "contains the proposal's lead organizer country code" do
      country_code = @EFS.find_country(@proposal.lead_organizer).alpha2
      expect(@result).to include(%(codeAlpha2: "#{country_code}"))
    end

    it "contains the proposal's supporting organizer's info" do
      update_organizers

      supporting_org, country_code = @EFS.supporting_organizers.sample
      expect(@result).to include(%(address: "#{supporting_org.email}"))
      expect(@result).to include(%(nameGiven: "#{supporting_org.firstname}"))
      expect(@result).to include(%(nameSurname: "#{supporting_org.lastname}"))
      expect(@result).to include(%(name: "#{supporting_org.affiliation}"))
      expect(@result).to include(%(codeAlpha2: "#{country_code}"))
    end
  end
end
