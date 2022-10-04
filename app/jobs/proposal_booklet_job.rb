class ProposalBookletJob < ApplicationJob
  queue_as :default

  def perform(proposal_ids, table, counter, current_user)
    @errors = ""
    create_file(proposal_ids, table, counter, current_user)
    if @errors.present?
      ActionCable.server.broadcast("proposal_booklet_channel", { alert:
          @errors })
    else
      ActionCable.server.broadcast("proposal_booklet_channel", { success:
          "Created proposals booklet. Now, it will download itself." })
    end
  end

  private

  def create_file(proposal_ids, table, counter, current_user)
    temp_file = "propfile-#{current_user.id}-proposals-booklet.tex"
    if counter == 1
      single_proposal_booklet(proposal_ids, temp_file, table, current_user)
    else
      multiple_proposals_booklet(proposal_ids, temp_file, table, current_user)
    end
  end

  def single_proposal_booklet(proposal_ids, temp_file, table, current_user)
    proposal = Proposal.find_by(id: proposal_ids)
    BookletPdfService.new(proposal.id, temp_file, 'all', current_user).single_booklet(table)
    fh = File.open("#{Rails.root}/tmp/#{temp_file}")
    latex_infile = fh.read
    latex_infile = LatexToPdf.escape_latex(latex_infile) if proposal.no_latex
    proposals_macros = proposal.macros
    write_file(proposals_macros, latex_infile)
  end

  def write_file(proposals_macros, latex_infile)
    latex = "#{proposals_macros}\n\\begin{document}\n#{latex_infile}"
    ac = ActionController::Base.new
    pdf_file = ac.render_to_string layout: "booklet", inline: latex, formats: [:pdf]
    write_new_file(pdf_file)
  rescue StandardError => e
    Rails.logger.info { "\n\nLaTeX error:\n #{e.message}\n\n" }
    @errors << "LaTeX error: #{e.message}"
  end

  def write_new_file(pdf_file)
    pdf_path = Rails.root.join('tmp/booklet-proposals.pdf')
    File.open(pdf_path, "w:UTF-8") do |file|
      file.write(pdf_file)
    end
  end

  def multiple_proposals_booklet(proposal_ids, temp_file, table, current_user)
    create_booklet(proposal_ids, temp_file, table, current_user)
    latex_infile = check_file_existence(proposal_ids, temp_file, table, current_user)
    proposals_macros = ExtractPreamblesService.new(proposal_ids).proposal_preambles
    write_file(proposals_macros, latex_infile)
  end

  def create_booklet(proposal_ids, temp_file, table, current_user)
    BookletPdfService.new(proposal_ids.split(','), temp_file, 'all', current_user)
                     .multiple_booklet(table, proposal_ids)
  rescue StandardError => e
    Rails.logger.info { "\n\nLaTeX error:\n #{e.message}\n\n" }
    @errors << "LaTeX error: #{e.message}"
  end

  def check_file_existence(proposal_ids, temp_file, table, current_user)
    create_booklet(proposal_ids, temp_file, table, current_user) unless File.exist?("#{Rails.root}/tmp/#{temp_file}")
    fh = File.open("#{Rails.root}/tmp/#{temp_file}")
    fh.read
  end
end
