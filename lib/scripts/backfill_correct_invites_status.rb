# frozen_string_literal: true

p 'Started updating invite records with status `confirmed`, response `maybe` to have correct status as `pending`'
Invite.where(status: :confirmed, response: :maybe).update_all(status: :pending)
p 'Finished update'
