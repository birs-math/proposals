import { Controller } from 'stimulus'
import toastr from 'toastr'

export default class extends Controller {
  static targets = ['target', 'template', 'targetOne', 'templateOne']
  static values = {
    wrapperSelector: String,
    maxOrganizer: Number,
    maxParticipant: Number,
    organizer: Number,
    participant: Number
  }
 
  initialize () {
    this.wrapperSelector = this.wrapperSelectorValue || '.nested-invites-wrapper'
  }

  addCoOrganizers (e) {
    e.preventDefault()

    let content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString())
    if (this.organizerValue < this.maxOrganizerValue) {
      this.targetTarget.insertAdjacentHTML('beforebegin', content)
      this.organizerValue += 1
    } else {
      toastr.error("You can't add more because the maximum number of Co Organizer invitations has been sent.")
    }
  }

  addParticipants (e) {
    e.preventDefault()

    let contentOne = this.templateOneTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString())
    if (this.participantValue < this.maxParticipantValue) {
      this.targetOneTarget.insertAdjacentHTML('beforebegin', contentOne)
      this.participantValue += 1
    } else {
      toastr.error("You can't add more because the maximum number of Participant invitations has been sent.")
    }
  }

  remove (e) {
    e.preventDefault()

    let wrapper = e.target.closest(this.wrapperSelector)
    if (wrapper.dataset.newRecord === 'true') {
      wrapper.remove()
    } else {
      wrapper.style.display = 'none'

      let input = wrapper.querySelector("input[name*='_destroy']")
      input.value = '1'
    }
  }

  invitePreview ()  {
    event.preventDefault()

    let id = event.currentTarget.dataset.id;
    let invitedAs = ''
    $.post(`/submit_proposals?proposal=${id}.js`,
      $('form#submit_proposal').serialize(), function(data) {
        if ( data.invited_as ) {
          if(data.invited_as === 'participant') {
            $('#invited_as_pre').text(data.invited_as)
            invitedAs = 'Participant'
            $('#invited_as_title').text(invitedAs)
          } else {
            invitedAs = 'supporting organizer'
            $('#invited_as_pre').text(invitedAs)
            invitedAs = 'Supporting Organizer'
            $('#invited_as_title').text(invitedAs)
          }
          $("#email-preview").modal('show')
        }
      }
    ) 
    .fail(function(response) {
      let errors = response.responseJSON
      $.each(errors, function(index, error) {
        toastr.error(error)
      })
    });
  }

  sendInvite () {
    let id = event.currentTarget.dataset.id;
    let invitedAs = $('#invited_as_pre').text()
    let inviteId = 0
    if (invitedAs === 'participant') {
      invitedAs = 'Participant'
      inviteId = event.currentTarget.dataset.participant || 0
    } else {
      invitedAs = 'Co Organizer'
      inviteId = event.currentTarget.dataset.organizer || 0
    }
    $.post(`/proposals/${id}/invites/${inviteId}/invite_email?invited_as=${invitedAs}`, function() {
      toastr.success("Invitation has been sent!")
      setTimeout(function() {
        window.location.reload();
      }, 2000)
    })
  }
}
