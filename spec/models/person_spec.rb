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
  end

  describe 'associations' do
    it { should belong_to(:user).optional(true) }
    it { should have_many(:proposals).through(:proposal_roles) }
  end

  describe '#fullname' do
    let(:person) { create(:person) }
    let(:fullname) { person.firstname + ' ' + person.lastname }
    it 'returns fullname of person' do
      expect(person.fullname).to eq(fullname)
    end
  end

  describe '#lead_organizer_attributes' do
    let(:person) { create(:person) }
    before do
      person.is_lead_organizer = true
      person.update(street_1: nil, city: nil)
    end
    it '' do 
      expect(person.errors.full_messages).to eq(["Street 1 can't be blank", "City can't be blank"])
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

  describe '#common_fields' do
    context 'when multiple fields are blank' do
      let(:person) { create(:person) }
      before do
        person.update(affiliation: nil, academic_status: nil, first_phd_year: nil, country:nil)
      end
      it '' do 
        expect(person.errors.full_messages).to eq(["Main affiliation/institution can't be blank", "Academic status can't be blank", "Year of PhD can't be blank", "Country can't be blank"])
      end
    end
    context 'when first phD yaer is N/A' do
      let(:person) { create(:person) }

      before do
        person.update(first_phd_year: :'N/A')        
      end 
      it '' do
        expect(person.first_phd_year).to eq nil 
      end
    end
    context 'When other academic status is blank' do
     let(:person) { create(:person, academic_status: 'Other') }
      before do
        person.update(other_academic_status: nil)
      end
      it '' do 
        expect(person.errors.full_messages).to eq(["Other academic status Please indicate your academic status."])
      end 
    end
    context 'When region is blank' do
      let(:person) { create(:person) }
      before do
        person.update(region: nil, country: 'Canada')
      end
      it '' do 
        expect(person.errors.full_messages).to eq(["Missing data:  You must select a Province"])
      end
    end
    context 'When State is blank' do
      let(:person) { create(:person, country: 'Canada') }
      before do
        person.update(state: nil, province: "xyz")   
      end
      it '' do
        expect(person.region).to eq(person.province)
      end
    end  
    context 'When Province is blank' do
      let(:person) { create(:person, country: 'United States of America') }
      before do
        person.update(state: "xyz", province: nil)   
      end
      it '' do
        expect(person.region).to eq(person.state)
      end
    end     
  end
end
