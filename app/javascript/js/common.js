$(document).ready(function() {
  $(document).on('hide.bs.modal', '#email-preview', function() {
    window.location.reload()
  });

  $(document).on('hide.bs.modal', '#user-window', function() {
    window.location.reload()
  });

  $('.latex-show-more').click(function() {
    var $this = $(this);
    $this.toggleClass('latex-show-more');
    if($this.hasClass('latex-show-more')) {
      $this.text('Show full error log');
    } else {
      $this.text('Hide full error log');
    }
  });

  $('[id^="chartjs"]').each(function() {
    this.style.height = '200px'
  })

  $('#add-more-participant, #add-more-organizer').click();

  // Show value of slider bar for shedule run
  var slider = document.getElementById("slider");
  var slider_value = document.getElementById("slider-val");
  slider_value.innerHTML = slider.value;

  slider.oninput = function() {
    slider_value.innerHTML = this.value;
  }
});
