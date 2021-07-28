import { Controller } from "stimulus"
import Rails from '@rails/ujs'
import toastr from 'toastr'

export default class extends Controller {
  static targets = [ "files" , "collector" ]

  uploadFile(event) {
    if(event.target.files) {
      var data = new FormData()
      for (let i = 0; i < event.target.files.length; i++) {
        var f = event.target.files[`${i}`]
        data.append('files[]', f)
      }
      let url = "/proposals/" + event.target.dataset.proposalFormId + "/upload_file"
      Rails.ajax({
        url,
        type: "POST",
        data,
        success() {
            location.reload()
            toastr.success("Upload successful.")
        },
        error() {
            toastr.error("Upload of PDF file failed.")
        }
      })
    }
  }

  removeFile() {
    let url = "/proposals/" + event.target.dataset.proposalId + "/remove_file"
    var data = new FormData()
    data.append("attachment_id", event.target.dataset.attachmentId)
    Rails.ajax({
      url,
      type: "POST",
      data
    })
  }
}
