import { Controller } from 'stimulus'
import Rails from '@rails/ujs'
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

  addOrganizers (e) {
    e.preventDefault()

    let content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString())
    if (this.organizerValue < this.maxOrganizerValue) {
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
    if (this.participantValue < this.maxParticipantValue) {
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
    let invitedAs = event.currentTarget.id;
    $.get(`/invites/show_invite_modal/${id}`, function(data) {
        $('#invite-modal-body').html(data)
        $('#invite-modal').modal('show')
      }
    )
  }

  editLeadPreview () {
    event.preventDefault()
    let id = event.currentTarget.dataset.id;
    let invitedAs = event.currentTarget.id;
    $.get(`/person/show_person_modal/${id}`, function(data) {
        $('#invite-person-body').html(data)
        $('#person-modal').modal('show')
      }
    )
  }

  sendInvite () {
    let id = event.currentTarget.dataset.id;
    let invitedAs = ''
    let inviteId = 0
    let _this = this
    let inviteParticipant = event.currentTarget.dataset.participant || 0
    let inviteOrganizer = event.currentTarget.dataset.organizer || 0
    var body = $('#email_body').text()
    $.post(`/submit_proposals/create_invite?proposal=${id}`,
      $('form#submit_proposal').serialize(), function(data) {
        if (body.toLowerCase().includes("supporting organizer")) {
          invitedAs = 'Organizer'
          inviteId = inviteOrganizer
        }
        else if (body.toLowerCase().includes("participant")) {
          invitedAs = 'Participant'
          inviteId = inviteParticipant
        }
        _this.sendInviteEmails(id, invitedAs, inviteId, data)
      }
    )
    .fail(function(response) {
      let errors = response.responseJSON
      $.each(errors, function(index, error) {
        toastr.error(error)
      })
    });
  }

  sendInviteEmails(id, invitedAs, inviteId, data) {
    var url = ''
    if(data.errors.length > 0 && data.counter === 0) {
       $.each(data.errors, function(index, error) {
        toastr.error(error)
        setTimeout(function() {
          window.location.reload();
        }, 2000)
      })
    }
    else if(data.errors.length > 0 && data.counter > 0) {
      $.each(data.errors, function(index, error) {
        toastr.error(error)
      })
      url = `/proposals/${id}/invites/${inviteId}/invite_email?invited_as=${invitedAs}`
      Rails.ajax({
        url,
        type: "POST",
        success: () => {
          setTimeout(function() {
            window.location.reload();
          }, 3000)
        }
      })
    }
    else {
      url = `/proposals/${id}/invites/${inviteId}/invite_email?invited_as=${invitedAs}`
      Rails.ajax({
        url,
        type: "POST",
        success: () => {
          toastr.success('Invitation has been sent!')
          setTimeout(function() {
            window.location.reload();
          }, 2000)
        }
      })
    }
  }
}
