import { Controller } from 'stimulus'
import Rails from '@rails/ujs'
import toastr from 'toastr'

export default class extends Controller {
  static targets = ['target', 'template', 'targetOne', 'templateOne']
  static values = {
    wrapperSelector: String,
    maxOrganizer: Number,
    maxParticipant: Number,
    venueCapacity: Number,
    organizer: Number,
    participant: Number
  }

  initialize () {
    this.wrapperSelector = this.wrapperSelectorValue || '.nested-invites-wrapper'
  }

  addOrganizers (e) {
    e.preventDefault()

    let content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString())
    if ((this.organizerValue + this.participantValue) >= this.venueCapacityValue) {
      toastr.error("You can't add more organizers because the capacity of the venue has been reached.")
    } else if (this.organizerValue < this.maxOrganizerValue) {
        this.targetTarget.insertAdjacentHTML('beforebegin', content)
        this.organizerValue += 1
        if($('#organizer_deadline').val())
        {
          $('.organizer-deadline-date').last().val($('#organizer_deadline').val())
        }
    } else {
      toastr.error("You can't add more because the maximum number of Organizer invitations has been sent.")
    }
  }

  addParticipants (e) {
    e.preventDefault()

    let contentOne = this.templateOneTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString())
    if ((this.organizerValue + this.participantValue) >= this.venueCapacityValue) {
      toastr.error("You can't add more participants because the capacity of the venue has been reached.")
    } else if (this.participantValue < this.maxParticipantValue) {
        this.targetOneTarget.insertAdjacentHTML('beforebegin', contentOne)
        this.participantValue += 1
        if($('#participant_deadline').val())
        {
          $('.participant-deadline-date').last().val($('#participant_deadline').val())
        }
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
    let role = event.target.id
    if( role === 'organizer' ) {
      if (document.getElementById("participant_firstname") != null){
        document.getElementById("participant_firstname").disabled = true;
        document.getElementById("participant_lastname").disabled = true;
        document.getElementById("participant_email").disabled = true;
        document.getElementById("participant_deadline").disabled = true;
        document.getElementById("participant_invited_as").disabled = true;
      }
    }else if( role === 'participant' ){
      if (document.getElementById("organizer_firstname") != null){
        document.getElementById("organizer_firstname").disabled = true;
        document.getElementById("organizer_lastname").disabled = true;
        document.getElementById("organizer_email").disabled = true;
        document.getElementById("organizer_deadline").disabled = true;
        document.getElementById("organizer_invited_as").disabled = true;
      }
    }

    let id = event.currentTarget.dataset.id;
    let invitedAs = event.currentTarget.id
    $.post(`/submit_proposals/invitation_template?proposal=${id}&invited_as=${invitedAs}`, function(data) {
        $('#subject').text(data.subject)
        $('#email_body_preview').html(data.body)
        $('#email_body').text(data.body)
        $("#email-preview").modal('show')
      }
    )
  }

  editPreview ()  {
    event.preventDefault()
    let id = event.currentTarget.dataset.id;
    $.get(`/invites/show_invite_modal/${id}`, function(data) {
        $('#invite-modal-body').html(data)
        $('#invite-modal').modal('show')
      }
    )
  }

  editLeadPreview () {
    event.preventDefault()
    let id = event.currentTarget.dataset.id;
    $.get(`/person/show_person_modal/${id}`, function(data) {
        $('#invite-person-body').html(data)
        $('#person-modal').modal('show')
      }
    )
  }

  // TODO: do not send whole form when inviting
  sendInvite () {
    let id = event.currentTarget.dataset.id;
    $.post(`/submit_proposals/create_invite?proposal=${id}`,
      $('form#submit_proposal').serialize()
    ).done(function(response) {
      if (response.errors.length > 0) {
        $.each(response.errors, function(index, error) {
          toastr.error(error)
        })
      } else {
        toastr.success('Invitation has been sent!')
        setTimeout(function() {
          $('#email-preview').modal('hide')
        }, 2000)
      }
    });
  }
}
