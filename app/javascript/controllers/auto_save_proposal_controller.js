import { Controller } from "stimulus"

export default class extends Controller {

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
    } else {
      clearInterval(localStorage.getItem('interval'))
      localStorage.removeItem("interval");
    }
  }

  submitProposal (id) {
   $.post(`/submit_proposals?proposal=${id}`,
      $('form#submit_proposal').serialize(), function(data) {
    }) 
  }

  onFoucs () {
    this.autoSaveProposal();
  }

  onBlur () {
    let id = window.location.href.split('/').slice(-3)[1]
    this.submitProposal(id)
  }

  disconnect () {
    clearInterval(localStorage.getItem('interval'))
    localStorage.removeItem("interval");
  }
}
