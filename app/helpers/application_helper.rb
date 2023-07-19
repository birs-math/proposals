module ApplicationHelper
  include Pagy::Frontend

  def active_menu(target_path)
    return 'active' if request.path == target_path

    ''
  end

  def dashboard_menu
    return 'show' if request.path.in?(['/proposal_types', '/submitted_proposals', '/locations', '/proposal_forms',
                                       '/feedback'])
  end

  def dashboard_list
    return 'active' if request.path.in?(['/proposal_types', '/submitted_proposals', '/locations', '/proposal_forms',
                                         '/feedback'])
  end

  def proposal_menu
    return 'show' if request.path.in?(['/proposal_forms/new', '/proposals/new', '/proposals'])
  end

  def proposal_list
    return 'active' if request.path.in?(['/proposal_forms/new', '/proposals/new', '/proposals'])
  end

  def pages_menu
    return 'show' if request.path.in?(['/guidelines'])
  end

  def pages_list
    return 'active' if request.path.in?(['/guidelines'])
  end

  def feedback_menu
    return 'active' if request.path.in?(['/feedback/new'])
  end

  def faq_menu
    return 'active' if request.path.in?(['/faqs/new'])
  end

  def numbers_to_words
    {
      1 => 'one', 2 => 'two', 3 => 'three', 4 => 'four', 5 => 'five',
      6 => 'six', 7 => 'seven', 8 => 'eight', 9 => 'nine', 10 => 'ten'
    }
  end

  def turbo_stream_flash
    turbo_stream.prepend "flash", partial: "layouts/toastr"
  end
end
