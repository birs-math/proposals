# frozen_string_literal: true

# https://trello.com/c/zqOX8JjT/12-ams-subject-code-remove-99-other-from-the-list

query = ProposalAmsSubject.where(code: nil)
code_missing_count = query.count

p "Found #{code_missing_count} ProposalAmsSubject's missing code"

query.find_each do |proposal_ams_subject|
  p "Found #{proposal_ams_subject.summary}..."
  proposal = proposal_ams_subject.proposal

  # find second AMS Subject
  other_proposal_ams_subjects =
    proposal_ams_subject.proposal.proposal_ams_subjects.where.not(id: proposal_ams_subject.id)

  if other_proposal_ams_subjects.size > 1
    p "Warning: #{proposal.summary} has more than two AMS Subjects, skipping..."
    next
  end

  other_code = other_proposal_ams_subjects.first.code

  if other_code.nil?
    # Possible to manually map those records, but skip for now instead
    p "Warning: #{proposal.summary} has two AMS Subjects without code1 or code2, skipping..."
    next
  else
    # Map existing code attribute to one that is missing
    target_code = case other_code
                  when 'code1'
                    'code2'
                  when 'code2'
                    'code1'
                  end

    if target_code.nil?
      p "Warning: #{proposal.summary} has other ProposalAmsSubject with unknown code label: #{other_code}"
      next
    end

    proposal_ams_subject.update_attribute(:code, target_code)
    p "Updated #{proposal_ams_subject.summary}, proposal: #{proposal.summary} with code: #{target_code}, " \
      "other ProposalAmsSubject had code: #{other_code}"
  end
end
