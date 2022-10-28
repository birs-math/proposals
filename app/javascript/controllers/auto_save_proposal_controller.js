import { Controller } from "stimulus"

export default class extends Controller {

  connect() {
    this.onClickEdit();
  }

  autoSaveProposal () {
    let url = window.location.href.split('/').slice(-3)
    var interval;
    let _this = this

    if(url.includes('proposals') && url.includes('edit')) {
      let id = url[1]
      interval =  setInterval(function() {
        _this.submitProposal(id)
      }, 10000);
      localStorage.setItem('interval', interval)
      clearInterval(localStorage.getItem('interval'))
      localStorage.removeItem("interval");
    } else {
      clearInterval(localStorage.getItem('interval'))
      localStorage.removeItem("interval");
    }
  }

  submitProposal (id) {
   $.post(`/submit_proposals?proposal=${id}`,
      $('form#submit_proposal').serialize(), function() {}) 
  }

  onFocus () {
    this.autoSaveProposal();
  }


  onClickEdit() {
      let assigned_size_value = $('#assigned_size').val()
      if(assigned_size_value == "Full")
        document.getElementById("same_week_as").disabled = true;
      else
        document.getElementById("same_week_as").disabled = false;
  }

  onBlur () {
    let id = $('#proposal_id').val()
    let assigned_size_value = $('#assigned_size').val()
    if(assigned_size_value == "Full")
      document.getElementById("same_week_as").disabled = true;
    else
      document.getElementById("same_week_as").disabled = false;
    this.submitProposal(id)
  }

  disconnect () {
    clearInterval(localStorage.getItem('interval'))
    localStorage.removeItem("interval");
  }
}
