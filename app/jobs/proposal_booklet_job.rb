class ProposalBookletJob < ApplicationJob
  queue_as :default

  def perform(proposal_ids, table, counter, current_user)
    @current_user = current_user
    @proposal_ids = proposal_ids
    @table = table
    @counter = counter

    create_file

    ProposalBookletChannel.broadcast_to(
      current_user,
      { success: "Created proposals booklet. Now, it will download itself." }
    )
  rescue ActionView::Template::Error => e
    Rails.logger.info { "\n\nLaTeX error:\n #{e.message}\n\n" }
    log = create_log_record(e.cause)
    ProposalBookletChannel.broadcast_to(current_user, { alert: e.message, log_id: log.id })
  end

  private

  attr_reader :current_user, :proposal_ids, :table, :counter

  def create_file
    if counter == 1
      single_proposal_booklet
    else
      multiple_proposals_booklet
    end
  end

  def single_proposal_booklet
    proposal = Proposal.find_by(id: proposal_ids)
    BookletPdfService.new(proposal.id, temp_file, 'all', current_user).single_booklet(table)
    latex_infile = read_temp_file
    latex_infile = LatexToPdf.escape_latex(latex_infile) if proposal.no_latex
    proposals_macros = proposal.macros
    write_file(proposals_macros, latex_infile)
  end

  def write_file(proposals_macros, latex_infile)
    latex = "#{proposals_macros}\n\\begin{document}\n#{latex_infile}"
    pdf_contents = render_to_string layout: "booklet", inline: latex, formats: [:pdf]
    pdf_path = Rails.root.join('tmp', pdf_file)

    File.open(pdf_path, "w:UTF-8") do |file|
      file.write(pdf_contents)
    end
  end

  def render_to_string(...)
    ActionController::Base.new.render_to_string(...)
  end

  def multiple_proposals_booklet
    create_booklet
    latex_infile = check_file_existence
    proposals_macros = ExtractPreamblesService.new(proposal_ids).proposal_preambles
    write_file(proposals_macros, latex_infile)
  end

  def create_booklet
    BookletPdfService.new(proposal_ids.split(','), temp_file, 'all', current_user)
                     .multiple_booklet(table, proposal_ids)
  end

  def check_file_existence
    create_booklet unless File.exist?("#{Rails.root}/tmp/#{temp_file}")
    read_temp_file
  end

  def temp_file
    return @temp_file if defined?(@temp_file)

    identifier = proposal_ids.respond_to?(:each) ? proposal_ids.join('-') : proposal_ids
    @temp_file = "propfile-#{current_user.id}-#{identifier}-proposals-booklet.tex"
  end

  def pdf_file
    @pdf_file ||= "booklet-proposals-#{current_user.id}.pdf"
  end

  def read_temp_file
    File.read("#{Rails.root}/tmp/#{temp_file}")
  end

  def create_log_record(error)
    LatexToPdfLog.create(log: error.log.lines.last(20).join("\n"), file_name: temp_file)
  end
end
