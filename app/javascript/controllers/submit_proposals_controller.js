import { Controller } from "stimulus"
import Sortable from "sortablejs"
import Rails from '@rails/ujs'

export default class extends Controller {

  static targets = [ 'proposalType', 'locationSpecificQuestions', 'locationIds', 'text', 'tabs', 
                    'dragLocations' ]
  static values = { proposalTypeId: Number, proposal: Number }

  connect() {
    if(this.hasLocationIdsTarget) {
      this.handleLocationChange(Object.values(this.locationIdsTarget.selectedOptions).map(x => x.value))
      this.showSelectedLocations()
    }
  }

  handleLocationChange(locations) {
    if(event && event.type === 'change') {
      locations = [...event.target.selectedOptions].map(opt => opt.value)
      this.saveLocations()
    }

    fetch(`/proposal_types/${this.proposalTypeIdValue}/location_based_fields?ids=${locations}&proposal_id=${this.proposalValue}`)
      .then(response => response.text())
      .then(html => {
        this.locationSpecificQuestionsTarget.innerHTML = html
      });
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
}
