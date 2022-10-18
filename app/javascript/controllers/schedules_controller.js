import { Controller } from 'stimulus'
import toastr from 'toastr'

export default class extends Controller {

  runHmcProgram() {
    $.post(`/schedules/run_hmc_program`,
      $("#schedule_run_parameters").serialize(), function(response) {
        if (response.errors.length == 0){
        toastr.success("Started schedule optimization run!")
        }
        else{
          toastr.error(response.errors)
        }
      }
    )
    .fail(function(response) {
      let errors = response.responseJSON.errors
      $.each(errors, function(index, error) {
        toastr.error(error)
      })
    });
  }
}
