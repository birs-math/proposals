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
    @efs = EditFlowService.new(@proposal)
  end

  it 'has supporting organizers with countries' do
    @proposal.invites.where(invited_as: 'Organizer').each do |invite|
      expect(invite.person.country).not_to be_blank
    end
  end

  it 'accept a proposal' do
    expect(@efs.class).to eq(EditFlowService)
  end

  it "assigns country code of lead organizer" do
    country = @proposal.lead_organizer.country
    code = Country.find_country_by_name(country).alpha2
    expect(@efs.proposal_country.alpha2).to eq(code)
  end

  context '.ams_subject_code' do
    # rspec factory subjects setup needs revision!
    it 'returns the AMS subject code with -XX appended' do
      expect(@efs.ams_subject_code(:first)).to eq('123-XX')
    end

    it 'raises an exception if proposal has a missing AMS subject' do
      new_efs = EditFlowService.new(create(:proposal))
      expect { new_efs.ams_subject_code(:first) }.to raise_error(RuntimeError)
    end
  end

  context '.proposal_country' do
    it 'returns a Country object for the Lead Organizer' do
      expect(@efs.proposal_country).to be_a(Country)
      country = Country.find_country_by_name(@proposal.lead_organizer.country)
      expect(@efs.proposal_country).to eq(country)
    end

    it 'raises a RunTime error if there is no country for the organizer' do
      @proposal.lead_organizer.update_columns(country: nil)
      expect { @efs.proposal_country }.to raise_error(RuntimeError)
      @proposal.lead_organizer.update(country: 'France')
    end
  end

  context '.organizer_country' do
    before do
      @org_invite = @proposal.invites.first
    end

    it 'accepts an invite and returns a Country object' do
      # update_organizers
      org_country = @efs.organizer_country(@org_invite)
      expect(org_country).to be_a(Country)
      expect(org_country.name).to eq(@org_invite.person.country)
    end

    it 'raises a RunTime error if an unknown country is given' do
      person = @org_invite.person
      person.update(country: 'September')

      expect { @efs.organizer_country(@org_invite) }.to raise_error(RuntimeError)
      person.update(country: 'Italy')
    end
  end

  it ".supporting_organizers" do
    organizers = @efs.supporting_organizers
    expect(organizers.count).to eq(3)
    expect(organizers.first.class).to eq(Array)

    first_org = @proposal.invites.first.person
    country_code = Country.find_country_by_name(first_org.country).alpha2
    supporting_organizer1 = [first_org, country_code]
    expect(organizers.first).to eq(supporting_organizer1)
  end

  it ".co_authors contains the proposal's supporting organizer's info" do
    supporting_org, country_code = @efs.supporting_organizers.sample
    result = @efs.co_authors
    expect(result).to include(%(address: "#{supporting_org.email}"))
    expect(result).to include(%(nameGiven: "#{supporting_org.firstname}"))
    expect(result).to include(%(nameSurname: "#{supporting_org.lastname}"))
    expect(result).to include(%(name: "#{supporting_org.affiliation}"))
    expect(result).to include(%(codeAlpha2: "#{country_code}"))
  end

  context ".query" do
    before do
      @result = @efs.query
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
      country_code = @efs.find_country(@proposal.lead_organizer).alpha2
      expect(@result).to include(%(codeAlpha2: "#{country_code}"))
    end
  end
end
