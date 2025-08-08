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
          expect(invite.person.firstname).to eq(invite.firstname)
          expect(invite.person.lastname).to eq(invite.lastname)
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

        it 'changes invite firstname and lastname to match person' do
          invite.update_invited_person
          invite.reload

          expect(invite.firstname).to eq(existing_person.firstname)
          expect(invite.lastname).to eq(existing_person.lastname)
        end
      end
    end
  end

  describe 'expired status' do
    let(:invite) { create(:invite, status: 'pending', deadline_date: 1.day.ago) }

    it 'includes expired in status enum' do
      expect(Invite.statuses).to include('expired' => 4)
    end

    it 'can be set to expired status' do
      invite.update!(status: 'expired')
      expect(invite.expired?).to be true
    end

    it 'returns true for expired? when deadline is past' do
      expect(invite.expired?).to be true
    end

    it 'returns false for expired? when deadline is future' do
      invite.update!(deadline_date: 1.day.from_now)
      expect(invite.expired?).to be false
    end
  end

  describe '.expire_overdue_invitations' do
    let!(:expired_invite) { create(:invite, status: 'pending', deadline_date: 1.day.ago) }
    let!(:active_invite) { create(:invite, status: 'pending', deadline_date: 1.day.from_now) }
    let!(:confirmed_invite) { create(:invite, status: 'confirmed', deadline_date: 1.day.ago) }

    it 'expires only pending invitations past deadline' do
      expired_invitations = Invite.expire_overdue_invitations
      
      expect(expired_invitations).to include(expired_invite)
      expect(expired_invitations).not_to include(active_invite)
      expect(expired_invitations).not_to include(confirmed_invite)
    end

    it 'updates status to expired' do
      Invite.expire_overdue_invitations
      
      expired_invite.reload
      expect(expired_invite.status).to eq('expired')
      expect(expired_invite.expired_at).to be_present
    end

    it 'does not affect active invitations' do
      Invite.expire_overdue_invitations
      
      active_invite.reload
      expect(active_invite.status).to eq('pending')
    end
  end

  describe 'scopes' do
    let!(:pending_invite) { create(:invite, status: 'pending') }
    let!(:confirmed_invite) { create(:invite, status: 'confirmed') }
    let!(:expired_invite) { create(:invite, status: 'expired') }
    let!(:cancelled_invite) { create(:invite, status: 'cancelled') }

    it 'active scope excludes expired, cancelled, and declined invitations' do
      active_invites = Invite.active
      expect(active_invites).to include(pending_invite, confirmed_invite)
      expect(active_invites).not_to include(expired_invite, cancelled_invite)
    end

    it 'expired scope finds pending invitations past deadline' do
      expired_invite.update!(deadline_date: 1.day.ago)
      expired_invitations = Invite.expired
      expect(expired_invitations).to include(expired_invite)
    end
  end
end
