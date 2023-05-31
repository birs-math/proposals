import { Controller } from "stimulus"

export default class extends Controller {

  connect() {
    this.onBlur();
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

  onBlur () {
    let url = window.location.href.split('/').slice(-3)
    let assigned_size_value = $('#assigned_size').val()
    if((url.includes('edit') && assigned_size_value == "Full") || (url.includes('submitted_proposals') && assigned_size_value == "Full"))
    {
      document.getElementById("same_week_as").disabled = true;
      document.getElementById("same_week_as").value = "";
    }
    else if (url.includes('edit') && assigned_size_value == "Half")
    {
      document.getElementById("same_week_as").disabled = false;
    }
    else if (url.includes('submitted_proposals') && assigned_size_value == "Half")
    {
      document.getElementById("same_week_as").disabled = true;
    }
  }

  disconnect () {
    clearInterval(localStorage.getItem('interval'))
    localStorage.removeItem("interval");
  }
}
