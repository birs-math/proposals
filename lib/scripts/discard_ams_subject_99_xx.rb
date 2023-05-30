# frozen_string_literal: true

# https://trello.com/c/zqOX8JjT/12-ams-subject-code-remove-99-other-from-the-list

ams_subject = AmsSubject.find_by(code: '99-XX')

if ams_subject
  Rails.logger.debug 'Found AMS subject with code 99-XX'
  ams_subject.discard!
  Rails.logger.debug 'Soft deleted AMS subject with code 99-XX'
else
  Rails.logger.debug 'Did not found AMS subject with code 99-XX'
end
