require 'rails_helper'

RSpec.describe Invite, type: :model do
  describe 'validations' do
    it 'has valid factory' do
      expect(build(:invite)).to be_valid
    end

    it 'requires a firstname' do
      invite = build(:invite, firstname: '')
      expect(invite.valid?).to be_falsey
    end

    it 'requires a lastname' do
      invite = build(:invite, lastname: '')
      expect(invite.valid?).to be_falsey
    end

    it "requires an email" do
      invite = build(:invite, email: '')
      expect(invite.valid?).to be_falsey
    end

    it "requires an invite as" do
      invite = build(:invite, invited_as: '')
      expect(invite.valid?).to be_falsey
    end

    it "requires an invite as" do
      invite = build(:invite, deadline_date: '')
      expect(invite.valid?).to be_falsey
    end
  end

  describe 'associations' do
    it { should belong_to(:proposal) }
    it { should belong_to(:person) }
  end

  describe '#email_downcase' do
    let(:invite) { create(:invite, invited_as: "Organizer") }
    it "downcase email if it contains uppercase" do
      invite.update_column(:email, 'TEST@Test.com')
      expect(invite.email_downcase).to eq 'test@test.com'
    end

    it "downcase email if it contains no uppercase" do
      invite.update_column(:email, 'test@test.com')
      expect(invite.email_downcase).to eq nil
    end
  end

  describe '#invited_as?' do
    let(:invite) { create(:invite, invited_as: "Organizer") }

    it "returns a Supporting Organizer" do
      expect(invite.humanize_invited_as).to eq('Supporting Organizer')
    end
  end

  describe '#update_invited_person' do
    let(:invite) { create(:invite, invited_as: "Organizer") }
    let(:existing_person) do
      create(:person, email: invite.email, firstname: invite.firstname, lastname: invite.lastname)
    end

    it "updates affiliation" do
      invite.update_invited_person("Test Affiliation")

      expect(invite.person.affiliation).to eq("Test Affiliation")
    end

    context 'when email changed' do
      before do
        invite.update(email: 'new_email_address@testmail.com')
      end

      context 'when email is not taken' do
        it { expect(Person.exists?(email: invite.email)).to be_falsey }

        it 'creates new person if does not exist' do
          expect { invite.update_invited_person }.to change(Person, :count).by(1)
          expect(invite.person.email).to eq(invite.email)
        end
      end

      context 'when email is taken' do
        before { existing_person }

        it { expect(Person.exists?(email: invite.email)).to be_truthy }

        it 'assigns existing person to invite' do
          expect { invite.update_invited_person }.to change(Person, :count).by(0)
          invite.reload
          expect(invite.person_id).to eq(existing_person.id)
        end
      end
    end
  end

  describe '#proposal_title' do
    context 'when proposal title present' do
      let(:invite) do
        create(:invite, firstname: 'New', lastname: 'Proposal', email: 'test@tes.com', invited_as: 'coorganizer')
      end
      before do
        invite.proposal.update(title: "New")
      end

      it { expect(invite.proposal.title).to eq 'New' }
    end
  end

  describe '#deadline_not_in_past' do
    context 'when deadline date is not in past' do
      let(:invite) do
        create(:invite, firstname: 'New', lastname: 'Proposal', email: 'test@test.com', invited_as: 'coorganizer')
      end

      it { expect(invite.deadline_date).to be > DateTime.now }
    end

    context 'when deadline date is in past' do
      let(:invite) do
        create(:invite, firstname: 'New', lastname: 'Proposal', email: 'test@test.com', invited_as: 'coorganizer')
      end
      before do
        invite.update(deadline_date: DateTime.now - 2.weeks)
      end
      it { expect(invite.errors.full_messages).to include("Deadline can't be in past") }
    end
  end

  describe '#generate_code' do
    context 'when code is present' do
      let(:invite) do
        create(:invite, firstname: 'New', lastname: 'Proposal', email: 'test@test.com', invited_as: 'coorganizer')
      end
      it { expect(invite.code).to be_present }
    end
  end
end
