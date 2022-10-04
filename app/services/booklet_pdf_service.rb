class BookletPdfService
  attr_reader :temp_file, :table, :user
  attr_accessor :proposal

  def initialize(proposal_id, file, input, user)
    @proposal = Proposal.find(proposal_id)
    @temp_file = file
    @input = input
    @user = user
  end

  def single_booklet(table)
    @table = table
    input = all_proposal_fields if @input == 'all'

    File.open("#{Rails.root}/tmp/#{temp_file}", "w:UTF-8") do |io|
      io.write(input)
    end
  end

  def multiple_booklet(table, proposals)
    @table = table
    @proposals_ids = proposals
    year = proposal&.year || (Date.current.year + 2)
    multiple_proposals_fields(year) if @input == 'all'
  end

  def self.format_errors(error)
    @error_object = error.cause # RailsLatex::ProcessingError
    @error_summary = @error_object.log.lines.last(20).join("\n")

    save_error_messages

    line_num = 1
    @error_object.src.each_line do |line|
      @error_output << (line_num.to_s + " #{line}")
      line_num += 1
    end
    @error_output << "\n</pre>\n\n"
  end

  private

  def save_error_messages
    @error_output = "<h2 class=\"text-danger\">LaTeX Error Log:</h2>\n\n"
    @error_output << "<h4>Last 20 lines:</h4>\n\n"
    @error_output << "<pre>\n#{@error_summary}\n</pre>\n\n"
    log_error_messages
    @error_output << "<pre class=\"collapse\" id=\"latex-error\">\n"
    @error_output << "#{@error_object.log}\n</pre>\n\n"

    @error_output << "<h2 class=\"text-danger p-4\">LaTeX Source File:</h2>\n\n"
    @error_output << "<pre id=\"latex-source\">\n"
  end

  def log_error_messages
    @error_output << %q[
      <%= link_to "Edit Proposal", edit_proposal_path(@proposal, tab: "tab-2"),
      class: 'btn btn-primary mb-4' %>]
    @error_output << %q(
      <button class="btn btn-primary mb-4 latex-show-more" type="button"
                     data-bs-toggle="collapse" data-bs-target="#latex-error"
                     aria-expanded="false" aria-controls="latex-error">
              Show full error log
      </button>')
  end

  def all_proposal_fields
    return 'Proposal data not found!' if proposal.blank?

    year = proposal&.year || (Date.current.year + 2)
    title_page(year)

    if @table == "toc"
      proposal_table_of_content
    else
      single_proposal_without_content
    end
    @text
  end

  def proposal_title(proposal)
    proposal.no_latex ? delatex(proposal&.title) : proposal&.title
  end

  def delatex(string)
    return '' if string.blank?

    LatexToPdf.escape_latex(string)
  end

  def title_page(year)
    @text = "\n\\thispagestyle{empty}\n"
    @text << "\\begin{center}\n"
    @text << "\\includegraphics[width=4in]{birs_logo.jpg}\\\\[30pt]\n"
    @text << "{\\writeblue\\titlefont Banff International\\\\[10pt]
                Research Station\\\\[0.5in]\n"
    @text << "#{year} Proposals}\n"
    @text << "\\end{center}\n\n"
    @text << "\\newpage\n\n"
  end

  def proposal_table_of_content
    @text << "\\tableofcontents\n"
    @text << "\\addtocontents{toc}{ \\textbf{1. #{proposal.subject&.title}} }\n"
    @code = proposal.code.blank? ? '' : "#{proposal&.code}: "
    @text << "\\addcontentsline{toc}{section}{ #{@code} #{proposal_title(proposal)} }\n"
    single_proposal_heading
    @text
  end

  def single_proposal_without_content
    code = proposal.code.blank? ? '' : "#{proposal&.code}: "
    @text << "\\section*{\\centering #{code} #{proposal_title(proposal)} }\n\n"
    single_proposal_heading
    @text
  end

  def multiple_proposals_fields(year)
    title_page(year)
    case @table
    when "toc"
      @number = 0
      @text << "\\tableofcontents"
      proposals_with_content
    when "ntoc"
      proposals_without_content
    end
    @text
  end

  def proposals_with_content
    proposals = Proposal.where(id: @proposals_ids.split(','))
    subjects_with_proposals = selected_proposals_subjects(proposals)
    subjects_with_proposals.each_with_index do |subject, iteration|
      @subject = Subject.find_by(id: subject.first)
      check_subject
      @proposals_objects = subject.last
      subject_proposals(iteration, proposals.count)
    end
    @latex_text
  end

  def selected_proposals_subjects(proposals)
    subjects_with_proposals = proposals.sort_by { |p| p.subject.title }.group_by(&:subject_id)
    first_subject_proposal(subjects_with_proposals)
    subjects_with_proposals
  end

  def check_subject
    return if @subject.blank?

    @number += 1
    @text << "\\addcontentsline{toc}{chapter}{\ \\large{#{@number}. #{@subject&.title}}}"
  end

  def subject_proposals(index, count)
    @proposals_objects&.sort_by { |p| p.code }&.each do |proposal|
      @proposal = proposal
      code = proposal.code.blank? ? '' : "#{proposal.code}: "
      @text << "\\addcontentsline{toc}{section}{ #{code} #{LatexToPdf.escape_latex(proposal&.title)}}"
      proposals_without_content
      check_no_latex(index, count)
    end
  end

  def proposals_without_content
    @text << "\\pagebreak"
    if @table == "toc"
      code = proposal.code.blank? ? '' : "#{proposal&.code}: "
      @text << "\\section*{\\centering #{code} #{proposal_title(proposal)} }\n"
      single_proposal_heading
    else
      proposals_heading
    end
  end

  def proposals_heading
    @proposals = @proposals_ids.split(",").first.to_i
    @proposals_ids.split(',').each_with_index do |id, index|
      proposal = Proposal.find_by(id: id)
      @proposal = proposal
      code = proposal.code.blank? ? '' : "#{proposal&.code}: "
      @text << "\\section*{\\centering #{code} #{proposal_title(proposal)}}\n "
      single_proposal_heading
      check_no_latex(index, @proposals_ids.split(',').count)
    end
  end

  def single_proposal_heading
    @text << "\n\\subsection*{#{proposal.proposal_type&.name} }\n\n"
    @text << participant_confirmed_count
    @text << lead_organizer_info
    @proposal = proposal
    all_text = ProposalPdfService.new(@proposal.id, @temp_file, 'all', @user).booklet_content
    @text << all_text if all_text.present?
  end

  def lead_organizer_info
    info = "\n\\subsection*{Lead Organizer}\n\n"
    info << "#{proposal.lead_organizer&.fullname} #{affil(proposal.lead_organizer)} \\\\ \n\n"
    info << "\\noindent #{delatex(proposal.lead_organizer&.email)}\n\n"
  end

  def affil(person)
    return '' if person.blank?

    affil = ""
    affil << " (#{person.affiliation}" if person&.affiliation.present?
    affil << ", #{person.department}" if person&.department.present?
    affil << ")" if person&.affiliation.present?

    delatex(affil)
  end

  def confirmed_organizers
    proposal.invites.where(status: "confirmed", invited_as: "Organizer")
  end

  def confirmed_participants
    proposal.invites.where(status: "confirmed", invited_as: "Participant")
  end

  def remove_organizers_from_participants
    confirmed_participants.pluck(:person_id) - confirmed_organizers.pluck(:person_id)
  end

  def participant_confirmed_count
    num_participants = remove_organizers_from_participants&.count || 0
    "#{num_participants} confirmed / #{proposal.proposal_type&.participant} maximum participants \\\\ \n"
  end

  def first_subject_proposal(subjects_with_proposals)
    @first_proposal_id = subjects_with_proposals.first[1].min_by(&:code).id
  end

  def check_no_latex(index = 0, count = 1)
    if index.zero? && (count == 1)
      write_to_file
    elsif count.positive? && index.zero?
      write_to_file
    else
      File.open("#{Rails.root}/tmp/#{temp_file}", "a:UTF-8") do |io|
        io.write(@text)
      end
    end
    read_file
  end

  def read_file
    @latex_infile = File.read("#{Rails.root}/tmp/#{temp_file}")
    @latex_infile = LatexToPdf.escape_latex(@latex_infile) if @proposal.no_latex
    @latex_text = @text
    @text = ''
  end

  private
  def write_to_file
    File.open("#{Rails.root}/tmp/#{temp_file}", "w:UTF-8") do |io|
      io.write(@text)
    end
  end
end
