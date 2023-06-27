namespace :birs do
  task default: 'birs:new_email_templates'

  desc "Add invitation BIRS Email Templates to database"
  task invitation_email_template: :environment do
    organizer_invitation = { title: "Invitation email for organizer",
                             subject: "BIRS Proposal: Invite for Supporting Organizer",
                             body: '
                              <p>Proposal_lead_organizer_name is putting together a proposal for a proposal_type titled "proposal_title" for submission to the Banff International Research Station.</p>
                              <p>If this proposal is successful, its proposed event would be some time during the 2023 calendar year.</p>
                              <p>This invitation is intended to gauge your interest in being a supporting organizer in this proposed workshop, if it were to be accepted. A positive response to the invitation does not confirm participation, but indicates your appreciation of the scientific content of the program.</p>
                              <p>This preliminary invitation is a required step in the proposal process. Your response would help the proposal organizers and proposal reviewers determine the appeal of this proposed workshop to the wider mathematical community.</p>
                              <p>To respond to this informal invitation, please indicate your interest in this proposal by following this link by invite_deadline_date:</p>
                              <p>invite_url</p>
                              <p>If you indicate a positive response (<i>Yes</i> or <i>Maybe</i>), you will also be asked to fill out a Diversity and Inclusion survey. This survey is mandatory, but it should only take a minute to fill out, and for all questions, you are welcome to select <b>Prefer not to answer</b>. Data collected through this survey is anonymous and non-identifying. It will help organizers ensure a balanced composition of the participant pool and showcase the diversity and inclusivity of the proposed program to the review committee.</p>
                              <p>Thank you for indicating your interest in this proposed workshop!</p>
                              <p>Banff International Research Station,<br>
                                and the organizing committee.</p>',
                             email_type: "organizer_invitation_type" }

    participant_invitation = { title: "Invitation email for participant",
                               subject: "BIRS Proposal: Invite for Participant",
                               body: '
                                <p>Proposal_lead_organizer_name is putting together a proposal for a proposal_type titled "proposal_title" for submission to the Banff International Research Station.</p>
                                <p>If this proposal is successful, its proposed event would be some time during the 2023 calendar year.</p>
                                <p>This invitation is intended to gauge your interest in being a participant in this proposed workshop, if it were to be accepted. A positive response to the invitation does not confirm participation, but indicates your appreciation of the scientific content of the program.</p>
                                <p>This preliminary invitation is a required step in the proposal process. Your response would help the proposal organizers and proposal reviewers determine the appeal of this proposed workshop to the wider mathematical community.</p>
                                <p>To respond to this informal invitation, please indicate your interest in this proposal by following this link by invite_deadline_date:</p>
                                <p>invite_url</p>
                                <p>If you indicate a positive response (<i>Yes</i> or <i>Maybe</i>), you will also be asked to fill out a Diversity and Inclusion survey. This survey is mandatory, but it should only take a minute to fill out, and for all questions, you are welcome to select <b>Prefer not to answer</b>. Data collected through this survey is anonymous and non-identifying. It will help organizers ensure a balanced composition of the participant pool and showcase the diversity and inclusivity of the proposed program to the review committee.</p>
                                <p>Thank you for indicating your interest in this proposed workshop!</p>
                                <p>Banff International Research Station,<br>
                                  and the organizing committee.</p>',
                               email_type: "participant_invitation_type" }

    unless EmailTemplate.exists?(email_type: organizer_invitation[:email_type])
      EmailTemplate.create(title: organizer_invitation[:title],
                           subject: organizer_invitation[:subject],
                           body: organizer_invitation[:body],
                           email_type: organizer_invitation[:email_type])
    end

    unless EmailTemplate.exists?(email_type: participant_invitation[:email_type])
      EmailTemplate.create(title: participant_invitation[:title],
                           subject: participant_invitation[:subject],
                           body: participant_invitation[:body],
                           email_type: participant_invitation[:email_type])
    end
  end

  desc "Add Liquid email templates"
  task liquid_email_templates: :environment do
    invite_reminder = {
      title: 'Invite reminder',
      email_type: :invite_reminder,
      subject: 'Please Respond – BIRS Proposal Invitation for {{ invited_role }}',
      body: <<~HTML
        <p>Dear {{ person_name }}:</p>
        <p>
          This is a friendly reminder to indicate your interest in being {{ invited_as }} a proposed {{ proposal_type }} titled “{{ proposal_title }}”, which is currently being organized by {{ all_organizers }}.
        </p>

        <p>Please indicate your interest in this proposal by following this link by {{ deadline_date }}:</p>

        <p><a href="{{ invite_url }}">{{ invite_url }}</a></p>

        <p>Thank you for indicating your interest in this proposed workshop!</p>

        <p>Banff International Research Station</p>
        <p>And the organizing committee.</p>
      HTML
    }

    confirmation_of_interest = {
      title: 'Invite acceptance of interest',
      email_type: :confirmation_of_interest,
      subject: 'BIRS Proposal Confirmation of Interest',
      body: <<~HTML
        <p>Dear {{ person_name }}:</p>
        <p>
          Thank you for indicating your interest in becoming a {{ invited_role }} for the proposed workshop titled, "{{ proposal_title }}", which is currently being organized by {{ all_organizers }}.
          The organizing committee will be in touch regarding future steps if the proposal is successful.
        </p>
        <p>Sincerely,</p>
        <p>The Banff International Research Station<br>
        and the Organizing Committee</p>
      HTML
    }

    invite_uncertain = {
      title: 'Invite uncertain',
      email_type: :invite_uncertain,
      subject: 'Invite Uncertain',
      body: <<~HTML
        <p>Dear {{ person_name }}:</p>
        <p>
          Thank you for letting us know that you will may be able to participate in the proposed workshop, "{{ proposal_title }}", currently being
          organized by  {{ lead_organizer }}.
          We will send you soft remainder regarding this and hope you will join us in future.
        </p>
        <p>Sincerely,</p>
        <p>Banff International Research Station</p>
      HTML
    }

    templates = [invite_reminder, confirmation_of_interest, invite_uncertain]

    templates.each do |template_hash|
      next if EmailTemplate.exists?(email_type: template_hash[:email_type])

      EmailTemplate.create(title: template_hash[:title],
                           subject: template_hash[:subject],
                           body: template_hash[:body],
                           email_type: template_hash[:email_type],
                           liquid_template: true)
    end
  end
end
