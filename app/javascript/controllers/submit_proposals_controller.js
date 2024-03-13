import { Controller } from "stimulus"
import Sortable from "sortablejs"
import Rails from '@rails/ujs'
import { Tooltip } from 'bootstrap'

import { get } from '@rails/request.js'

export default class extends Controller {

  static targets = [ 'proposalType', 'locationSpecificQuestions', 'locationIds', 'text', 'tabs',
                    'dragLocations', 'latexPreamble', 'latexBibliography', 'proposalVersion', 'yearSelect' ]
  static values = { proposalTypeId: Number, proposal: Number }

  connect() {
    if(this.hasLocationIdsTarget || $('#no_latex').is(':checked')) {
      this.handleLocationChange(Object.values(this.locationIdsTarget.selectedOptions).map((x) => x.value))
      this.showSelectedLocations()
    }
  }

  handleLocationChange(locations) {
    if(event && event.type === 'change') {
      locations = [...event.target.selectedOptions].map((opt) => opt.value)
      this.saveLocations()
    }

    if(this.hasProposalVersionTarget) {
      let version = $("#proposal_version").val()
      fetch(`/proposal_types/${this.proposalTypeIdValue}/location_based_fields?ids=${locations}&proposal_id=${this.proposalValue}&proposal_version=${version}`)
      .then((response) => response.text())
      .then((html) => {
        this.locationSpecificQuestionsTarget.innerHTML = html
      });
    }
    else {
      fetch(`/proposal_types/${this.proposalTypeIdValue}/location_based_fields?ids=${locations}&proposal_id=${this.proposalValue}`)
      .then((response) => response.text())
      .then((html) => {
        this.locationSpecificQuestionsTarget.innerHTML = html
      });
    }
  }

  saveLocations() {
    var _this = this
    $.post(`/submit_proposals?proposal=${_this.proposalValue}`,
      $('form#submit_proposal').serialize(), function() {
        _this.showSelectedLocations()
    })
  }

  showSelectedLocations() {
    var _this = this
    var locationList = ''
    fetch(`/proposals/${this.proposalValue}/locations.json`)
    .then((response) => response.json())
    .then((res) => {
      res.forEach(function (location) {
        locationList +=  `<p data-id='${location.id}'>${location.name}</p>`;
        _this.dragLocationsTarget.innerHTML = locationList
      })
      if(res.length === 0) {
        _this.dragLocationsTarget.innerHTML = ''
      }
    })

    var ele = this.dragLocationsTarget
    this.sortable = Sortable.create(ele, {
      onEnd: this.end.bind(this)
    })
  }

  end(event) {
    let id = event.item.dataset.id
    let data = new FormData()
    data.append("position", event.newIndex + 1)
    data.append("location_id", id)
    var url = `/proposals/${this.proposalValue}/ranking`
    Rails.ajax({
      url,
      type: "PATCH",
      data
    })
  }

  nextTab() {
    event.preventDefault();
    let currentTab
    let tab
    for (var i = 0; i < this.tabsTargets.length; i++) {
      tab = this.tabsTargets [`${i}`]
      if (tab.classList.contains('active')) {
        currentTab = tab
      }
    }
    let next = currentTab.parentElement.nextElementSibling
    if (next) {
      next.firstElementChild.click()
    }
  }

  previousTab() {
    event.preventDefault();
    let tab
    let currentTab
    for (var i = 0; i < this.tabsTargets.length; i++) {
      tab = this.tabsTargets [`${i}`]
      if (tab.classList.contains('active')) {
        currentTab = tab
      }
    }
    let previous = currentTab.parentElement.previousElementSibling
    if (previous) {
      previous.firstElementChild.click()
    }
  }

  saveProposal (id) {
   $.post(`/submit_proposals?proposal=${id}`,
      $('form#submit_proposal').serialize(), function() {})
  }

  hideAndSave() {
    let id = $('#proposal_id').val()
    this.saveProposal(id)

    if($('#no_latex').is(':checked')) {
      this.latexPreambleTarget.classList.add("hidden")
      this.latexBibliographyTarget.classList.add("hidden")
    } else {
      this.latexPreambleTarget.classList.remove("hidden")
      this.latexBibliographyTarget.classList.remove("hidden")
    }
  }

  copyToClipboard() {
    let text = document.querySelector(".modal-body code").innerText;
    navigator.clipboard.writeText(text).then(() => {
      console.log('Copying to clipboard was successful!');
      let tooltip = new Tooltip(document.getElementById('copyButton'), {
        title: "Copied!",
        trigger: 'manual'
      });
      tooltip.show();
      setTimeout(() => tooltip.hide(), 2000); // hides the tooltip after 2 seconds
    }, function(err) {
      console.error('Could not copy text: ', err);
    });
  }

  fillProposalYears(event) {
    let id = event.target.selectedOptions[0].value
    let target = this.yearSelectTarget.id

    get(`/proposal_types/${id}/years?target=${target}`, {
      responseKind: 'turbo-stream'
    })
  }
}
