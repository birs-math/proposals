namespace :birs do
  desc "Remove Unsupported Version of Invite on Production"
  task remove_unsupported_invite: :environment do
    invite = Invite.find_by_lastname('Česnavičius')
    person = Person.find_by_lastname('Česnavičius')
    invite.destroy!
    person.destroy!
  end
end
