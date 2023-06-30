import consumer from "./consumer"
import toastr from 'toastr'

consumer.subscriptions.create("ProposalBookletChannel", {
  connected() {
  },

  disconnected() {
  },

  received(data) {
    $(".proposal-booklet-btn").html("Create Booklet")
    $(".proposal-booklet-btn").removeClass("disabled");
    $(".proposal-booklet-ok-btn").removeClass("disabled");
    if (data['alert']){
      if (data['log_id']) {
        const new_path = new URL(window.location.origin + '/submitted_proposals/booklet_log')
        new_path.searchParams.append('log_id', data['log_id'])
        window.location.href = new_path.toString()
      } else {
        toastr.error(data['alert'])
      }
    } else if(data['success']) {
      document.getElementById('proposal_booklet').click();
      toastr.success(data['success'])
    }
  }
});
