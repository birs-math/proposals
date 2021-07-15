$(document).ready(function() {
  $(document).on('hide.bs.modal', '#email-preview', function(event) {
    window.location.reload()
  });

  $('.latex-show-more').click(function() {
    var $this = $(this);
    $this.toggleClass('latex-show-more');
    if($this.hasClass('latex-show-more')) {
      $this.text('Show more');
    } else {
      $this.text('Show less');
    }
  });

  $('[id^="chartjs"]').each(function(index, el) {
    this.style.height = '200px'
  })

  $('#add-more-participant, #add-more-organizer').click();
});
