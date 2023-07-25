import { Controller } from "stimulus"
import Rails from '@rails/ujs'
import toastr from 'toastr'
import Tagify from '@yaireo/tagify'

export default class extends Controller {
  static targets = [ 'toc', 'ntoc', 'templates', 'status', 'statusOptions', 'proposalStatus',
                     'organizersEmail', 'bothReviews', 'scientificReviews', 'ediReviews',
                    'reviewToc', 'reviewNToc', 'proposalLocation', 'locationOptions', 'location',
                    'outcome', 'selectedLocation', 'assignedSize' ]

  connect () {
    let proposalId = 0
    if (this.hasOrganizersEmailTarget) {
      var inputElm = this.organizersEmailTarget,
      tagify = new Tagify (inputElm);
    }
  }

  proposalsByTypeCheckbox() {
    return $(`input[data-type="${event.currentTarget.dataset.type}"]:checkbox`)
  }

  proposalsByTypeCheckboxChecked(type = event.currentTarget.dataset.type) {
    return $(`input[data-type="${type}"]:checked`)
  }

  editFlow() {
    var proposalIds = [];
    this.proposalsByTypeCheckboxChecked().each(function() {
      proposalIds.push(this.dataset.value);
    });
    if(typeof proposalIds[0] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      let data = new FormData()
      let selectedProposals = proposalIds.filter((x) => typeof x !== "undefined")
      data.append("ids", selectedProposals)
      var url = `/submitted_proposals/edit_flow`
      Rails.ajax({
        url,
        type: "POST",
        data,
        error: (response) => {
          let errors = response.errors
          toastr.error(errors)
        }
      })
    }
  }

  emailTemplate() {
    let value = event.currentTarget.value
    if(value) {
      let data = new FormData()
      data.append("email_template", value)
      var url = `/emails/email_template`
      Rails.ajax({
        url,
        type: "PATCH",
        data,
        success: (data) => {
          $('#birs_email_subject').val(data.email_template.subject)
          tinyMCE.activeEditor.setContent(data.email_template.body)
        }
      })
    }else {
      $('#birs_email_subject').val('')
      tinyMCE.activeEditor.setContent('')
    }
  }

  emailModal() {
    event.preventDefault()

    var proposalIds = [];
    this.proposalsByTypeCheckboxChecked().each(function() {
      proposalIds.push(this.dataset.value);
    });
    if(typeof proposalIds[0] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      let _this = this
      let selectedProposals = proposalIds.filter((x) => typeof x !== "undefined")
      $.post(`/emails/email_types`, { ids: selectedProposals }, function(data) {
        $.each(data.emails, function(index, email) {
          $('#to_organizer_emails').append(`<span class="ms-5">${index + 1}. ${email} </span><br>`)
        })
        const selectBox = _this.templatesTarget;
        selectBox.innerHTML = '';
        const opt = document.createElement('option');
        opt.innerHTML = ''
        selectBox.appendChild(opt);
        data.email_templates.forEach((item) => {
          const opt = document.createElement('option');
          opt.innerText = item
          selectBox.appendChild(opt);
        });
        $("#email-templates-proposals").text(selectedProposals)
        $("#email-template").modal('show')
      })
    }
  }

  sendEmails(event) {
    event.preventDefault();

    let proposalIds = $("#email-templates-proposals").text()
    if(this.templatesTarget.value) {
      $('#birs_email_body').val(tinyMCE.get('birs_email_body').getContent())
      var data = new FormData();
      var form_data = $('#approve_decline_proposals').serializeArray();
        $.each(form_data, function (key, input) {
          data.append(input.name, input.value);
      });

      var file_data = $('#decision_email_files')[0].files;
        for (var i = 0; i < file_data.length; i++) {
          data.append("attachments[]", file_data[i]);
        }

      $.ajax({
        url: `/submitted_proposals/approve_decline_proposals?proposal_ids=${proposalIds}`,
        method: "post",
        processData: false,
        contentType: false,
        data: data,
        success: function () {
          toastr.success("Emails have been sent!")
          setTimeout(function() {
            window.location.reload();
          }, 2000)
        },
        error: function (e) {
          let errors = e.responseJSON
          $.each(errors, function(index, error) {
            toastr.error(error)
          })
        }
      })
    }
    else {
      toastr.error("Please select any template")
    }
  }

  tableOfContent() {
    if(this.hasTocTarget) {
      this.tocTarget.checked = true;
    }
    var proposalIds = [];
    this.proposalsByTypeCheckboxChecked().each(function() {
      proposalIds.push(this.dataset.value);
    });
    if(typeof proposalIds[0] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      let selectedProposals = proposalIds.filter((x) => typeof x !== "undefined")
      $.post(`/submitted_proposals/table_of_content?proposals=${selectedProposals}`,
        $('form#submitted-proposal').serialize(), function(data) {
          $('#proposals').text(data.proposals)
          $("#table-window").modal('show')
        }
      )
    }
  }

  booklet() {
    let ids = $('#proposals').text()
    let table = ''
    if(this.tocTarget.checked) {
      table = "toc"
    }
    else {
      table = "ntoc"
    }
    if(table !== '') {
      $('.proposal-booklet-btn').html("Creating Booklet...")
      $('.proposal-booklet-btn').addClass('disabled');
      $(".proposal-booklet-ok-btn").addClass("disabled");
      $.post(`/submitted_proposals/proposals_booklet?proposal_ids=${ids}&table=${table}`,
        function() {
          toastr.success('Creating Proposal Booklet In progress. You will be notified once its done.')
      })
    }
  }

  handleStatus() {
    let currentProposalId = event.currentTarget.dataset.id
    for(var i = 0; i < this.statusOptionsTargets.length; i++){
      if(currentProposalId === this.statusOptionsTargets [`${i}`].dataset.id){
        this.proposalStatusTargets [`${i}`].classList.add("hidden")
        this.statusOptionsTargets [`${i}`].classList.remove("hidden")
      }
    }
  }

  handleLocations() {
    let currentLocationId = event.currentTarget.dataset.id
    for(var i = 0; i < this.locationOptionsTargets.length; i++){
      if(currentLocationId === this.locationOptionsTargets [`${i}`].dataset.id){
        this.proposalLocationTargets [`${i}`].classList.add("hidden")
        this.locationOptionsTargets [`${i}`].classList.remove("hidden")
      }
    }
  }

  proposalStatuses() {
    let id = event.currentTarget.dataset.id
    let status = ''
    let _this = this
    for(var i = 0; i < this.statusTargets.length; i++){
      if(id === this.statusTargets [`${i}`].dataset.id){
        status = this.statusTargets [`${i}`].value
        $.post(`/submitted_proposals/${id}/update_status?status=${status}`, function() {
          toastr.success('Proposal status has been updated!')
          setTimeout(function() {
            window.location.reload();
          }, 1000)
        })
        .fail(function(res) {
          res.responseJSON.forEach((msg) => toastr.error(msg))
        });
      }
    }
  }

  proposalLocations() {
    let id = event.currentTarget.dataset.id
    let location = ''
    let _this = this
    for(var i = 0; i < this.locationTargets.length; i++){
      if(id === this.locationTargets [`${i}`].dataset.id){
        location = this.locationTargets [`${i}`].value
        $.post(`/submitted_proposals/${id}/update_location?location=${location}`, function() {
          toastr.success('Proposal location has been updated!')
          setTimeout(function() {
            window.location.reload();
          }, 1000)
        })
        .fail(function(res) {
          res.responseJSON.forEach((msg) => toastr.error(msg))
        });
      }
    }
  }

  storeID() {
    this.proposalId = event.currentTarget.dataset.value
  }

  selectAllProposals() {
    let getId = ''
    this.proposalsByTypeCheckbox().each(function(){
      getId = document.getElementById(this.id)
      getId.checked = true
    });
  }

  unselectAllProposals() {
    let getId = ''
    this.proposalsByTypeCheckbox().each(function(){
      getId = document.getElementById(this.id)
      getId.checked = false
    });
  }

  invertSelectedProposals() {
    let checkbox = ''
    this.proposalsByTypeCheckbox().each(function(){
      checkbox = document.getElementById(this.id)
      if(checkbox.checked) {
        checkbox.checked = false
      } else {
        checkbox.checked = true
      }
    });
  }

  downloadCSV() {
    var proposalIds = [];
    this.proposalsByTypeCheckboxChecked().each(function() {
      proposalIds.push(this.dataset.value);
    });
    if(typeof proposalIds[0] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      let selectedProposals = proposalIds.filter((x) => typeof x !== "undefined")
      window.location = `/submitted_proposals/download_csv.csv?ids=${selectedProposals}`
    }
  }

  workshop() {
    var proposalIds = [];
    this.proposalsByTypeCheckboxChecked().each(function() {
      proposalIds.push(this.dataset.value);
    });
    if(typeof proposalIds[0] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      let selectedProposals = proposalIds.filter((x) => typeof x !== "undefined")
      $.ajax({
        url: `/submitted_proposals/send_to_workshop?ids=${selectedProposals}`,
        type: 'POST',
        success: () => {
          toastr.success('Export started')
          this.unselectAllProposals()
        },
        error: () => {
          toastr.error('Something unexpected happened')
        }
      })
    }
  }

  importReviews() {
    var proposalIds = [];
    this.proposalsByTypeCheckboxChecked().each(function() {
      proposalIds.push(this.dataset.value);
    });
    if(typeof proposalIds[0] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      let selectedProposals = proposalIds.filter((x) => typeof x !== "undefined")
      $('.import-reviews-btn').html("Importing...")
      $('.import-reviews-btn').addClass('disabled');
      $.post(`/submitted_proposals/import_reviews?proposals=${selectedProposals}`, function() {
        toastr.success("Import reviews In progress. You will be notified once its done.")
      })
    }
  }

  reviewsContent() {
    if(this.hasBothReviewsTarget && this.hasReviewTocTarget) {
      this.bothReviewsTarget.checked = true;
      this.reviewTocTarget.checked = true;
    }
    var proposalIds = [];
    this.proposalsByTypeCheckboxChecked().each(function() {
      proposalIds.push(this.dataset.value);
    });
    if(typeof proposalIds[0] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      let selectedProposals = proposalIds.filter((x) => typeof x !== "undefined")
      $("span#review-window-proposals").text(selectedProposals)
      $("#review-window").modal('show')
    }
  }

  reviewsBooklet() {
    let proposalIds = $("span#review-window-proposals").text()
    this.checkReviewType(proposalIds)
  }

  checkReviewType(proposalIds) {
    let reviewContentType = ''
    if(this.bothReviewsTarget.checked) {
      reviewContentType = "both"
    }
    else if(this.scientificReviewsTarget.checked) {
      reviewContentType = "scientific"
    }
    else {
      reviewContentType = "edi"
    }
    this.checkTableContentType(reviewContentType, proposalIds)
  }

  checkTableContentType(reviewContentType, proposalIds) {
    let table = ''
    if(this.reviewTocTarget.checked) {
      table = "toc"
    }
    else {
      table = "ntoc"
    }
    $('.reviews-booklet-btn').html("Creating Reviews Booklet...")
    $('.reviews-booklet-btn').addClass('disabled');
    $(".reviews-booklet-ok-btn").addClass("disabled");
    this.createReviewsBooklet(reviewContentType, proposalIds, table)
  }

  createReviewsBooklet(reviewContentType, proposalIds, table) {
    if(reviewContentType !== '') {
      $.ajax({
        url: `/submitted_proposals/reviews_booklet`,
        type: 'POST',
        data: {
          'proposals': proposalIds,
          table,
          reviewContentType
        },
        success: () => {
          toastr.success('Creating Reviews Booklet In progress. You will be notified once its done.')
        }
      })
    }
    else {
      toastr.error('Something went wrong.')
    }
  }

  removeFile(evt) {
    let dataset = evt.currentTarget.dataset

    $.ajax({
      url: `/reviews/${dataset.reviewId}/remove_file?attachment_id=${dataset.attachmentId}`,
      type: 'DELETE',
      data: {
        'attachment_id': dataset.attachmentId
      },
      success: () => {
        $(`#review-file${dataset.attachmentId}`).remove()
        toastr.success('Comment has successfully been removed.')
      },
      error: () => {
        toastr.error('Something went wrong.')
      }
    })
  }

  addFile(evt) {
    let dataset = evt.currentTarget.dataset
    if(evt.target.files) {
      var data = new FormData()
      var f = evt.target.files[0]
      var ext = f.name.split('.').pop();
      this.sendRequest(ext, data, f, dataset)
    }
  }

  reviewsExcelBooklet() {
    var proposalIds = [];
    this.proposalsByTypeCheckboxChecked().each(function() {
      proposalIds.push(this.dataset.value);
    });
    if(typeof proposalIds[0] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      window.location = `/submitted_proposals/reviews_excel_booklet.xlsx?proposals=${proposalIds}`
    }
  }

  sendRequest(ext, data, f, dataset) {
    if( ext === "pdf" || ext === "txt" || ext === "text") {
      data.append("file", f)
      var url = `/reviews/${dataset.reviewId}/add_file`
      Rails.ajax({
        url,
        type: "POST",
        data,
        success: () => {
          location.reload(true)
          toastr.success('File is attached successfully.')
        },
        error: (response) => {
          toastr.error(response.errors)
        }
      })
    }
    else {
      toastr.error('Only .pdf and .txt files are allowed.')
    }
  }

  outcomeLocationModal() {
   var proposalIds = [];
    this.proposalsByTypeCheckboxChecked().each(function() {
      proposalIds.push(this.dataset.value);
    });
    if(typeof proposalIds[0] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      $("span#outcome-location-size").text(event.currentTarget.dataset.type)
      $("#outcome-window").modal('show')
    }
  }

  outcomeLocation() {
    let proposalIds = [];
    let proposalType = $("span#outcome-location-size").text()
    this.proposalsByTypeCheckboxChecked(proposalType).each(function() {
      proposalIds.push(this.dataset.value);
    });
    if(typeof proposalIds[0] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      let outcome = this.outcomeTarget.value
      let location = this.selectedLocationTarget.value
      let size = this.assignedSizeTarget.value
      let url = `/submitted_proposals/proposal_outcome_location`
      $.ajax({
        url,
        type: "POST",
        data: {
          'proposal': {
            'id': proposalIds,
            outcome,
            'assigned_location_id': location,
            'assigned_size': size
          }
        },
        success: () => {
          toastr.success('Saved successfully!')
          setTimeout(function() {
            window.location.reload();
          }, 2000)
        }
      })
    }
  }
}
