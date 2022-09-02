require 'rails_helper'

RSpec.describe Person, type: :model do
  describe 'validations' do
    it 'has valid factory' do
      expect(build(:person)).to be_valid
    end

    it 'requires a firstname' do
      p = build(:person, firstname: '')
      expect(p.valid?).to be_falsey
    end

    it 'requires a lastname' do
      p = build(:person, lastname: '')
      expect(p.valid?).to be_falsey
    end

    it "requires an email" do
      p = build(:person, email: '')
      expect(p.valid?).to be_falsey
    end

    it "has a country" do
      p = build(:person)
      expect(p.country).not_to be_blank
    end
  end

  describe 'associations' do
    it { should belong_to(:user).optional(true) }
    it { should have_many(:reviews).dependent(:destroy) }
    it { should have_many(:proposals).through(:proposal_roles) }
  end

  describe '#fullname' do
    let(:person) { create(:person) }
    let(:fullname) { "#{person.firstname} #{person.lastname}" }
    it 'returns fullname of person' do
      expect(person.fullname).to eq(fullname)
    end
  end

  describe '#lead_organizer_attributes' do
    let(:proposal) { create(:proposal) }
    let(:proposal_roles) { create_list(:proposal_role, 3, proposal: proposal) }
    let(:person) { proposal_roles.last.person }
    before do
      proposal_roles.last.role.update(name: 'lead_organizer')
      person.lead_organizer?
      person.update(street_1: nil, city: nil, department: nil)
    end
    it 'validates mandatory fields' do
      expect(person.errors.full_messages).to eq(["Street 1 can't be blank",
                                                 "City can't be blank",
                                                 "Department can't be blank"])
    end
    it 'has a valid county' do
      expect(person.country).not_to be_blank
      expect(Country.find_country_by_name(person.country)).not_to be_nil
    end
  end

  describe '#region_type' do
    context 'when country is Canada' do
      let(:person) { create(:person, country: 'Canada') }

      it 'returns a province' do
        expect(person.region_type).to eq 'Province'
      end
    end
    context 'when country is United States of America' do
      let(:person) { create(:person, country: 'United States of America') }

      it 'returns a state' do
        expect(person.region_type).to eq 'State'
      end
    end
    context 'when country is XYZ' do
      let(:person) { create(:person, country: 'XYZ') }

      it 'returns a region' do
        expect(person.region_type).to eq 'Region'
      end
    end
  end

  describe '#draft_proposals?' do
    context 'when proposal status is draft' do
      let(:person) { create(:person, :with_proposals) }

      before { person.proposals.last.update(status: :draft) }
      it { expect(person.draft_proposals?).to be_truthy }
    end
  end

  describe '#person_proposal' do
    context 'when there is no proposal present with status submitted' do
      let(:person) { create(:person, :with_proposals) }

      it { expect(person.person_proposal).to be_falsey }
    end

    context 'when there is proposal present with status submitted' do
      let(:person) { create(:person, :with_proposals) }

      it 'submitted proposals' do
        person.proposals.first.update(status: "submitted")
        expect(person.person_proposal).to be_truthy
      end
    end
  end

  describe '#common_fields' do
    context 'when multiple fields are blank' do
      let(:person) { create(:person) }
      before do
        person.update(affiliation: nil, department: nil, academic_status: nil, first_phd_year: nil, country: nil)
      end
      it '' do
        expect(person.errors.full_messages).to eq(["Main affiliation/institution can't be blank",
                                                   "Department can't be blank",
                                                   "Academic status can't be blank", "Year of PhD can't be blank",
                                                   "Country can't be blank"])
      end
    end
    context 'when first phD yaer is N/A' do
      let(:person) { create(:person) }

      before do
        person.update(first_phd_year: :'N/A')
      end
    end
    context 'When other academic status is blank' do
      let(:person) { create(:person, academic_status: 'Other') }
      before do
        person.update(other_academic_status: nil)
      end
      it '' do
        expect(person.errors.full_messages).to eq(["Department can't be blank",
                                                   "Other academic status Please indicate your academic status."])
      end
    end
    context 'When region is blank' do
      let(:person) { create(:person) }
      before do
        person.update(region: nil, country: 'Turkey')
      end
      it '' do
        expect(person.errors.full_messages).to eq(["Department can't be blank"])
      end
    end
    context 'When State is present' do
      let(:person) { create(:person, country: 'Turkey') }
      before do
        person.update(state: "xyz", province: nil)
      end
      it '' do
        expect(person.region).to eq(person.province)
      end
    end
    context 'When Province is present' do
      let(:person) { create(:person, country: 'Egypt') }
      before do
        person.update(state: nil, province: "xyz")
      end
      it '' do
        expect(person.region).to eq(person.state)
      end
    end
  end
end
