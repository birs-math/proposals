class ProposalPdfService
  attr_reader :proposal, :temp_file, :table, :user, :file_errors

  include LatexAttachments

  def initialize(proposal_id, file, input, user, version = nil)
    @proposal = Proposal.find(proposal_id)
    @temp_file = file
    @input = input
    @user = user
    @file_errors = []
    @text = ""
    return if version.blank?

    @answers = @proposal.answers.where(version: version)
    @proposal_version = @proposal.proposal_versions.find_by(version: version)
  end

  def generate_pdf_with_reviews
    @input << "\\subsection*{Reviews:}\n\n\n"
    return unless proposal.reviews.first.files.attached?

    latex, file_errors = add_review_attachments(proposal.reviews.first, @input, proposal, file_errors)
    @input = latex if latex.present?
  end

  def generate_latex_file
    @input = @input.presence || 'Please enter some text.'
    @input = all_proposal_fields if @input == 'all'
    generate_pdf_with_reviews if proposal.reviews.count.positive?
    LatexToPdf.config[:arguments].delete('-halt-on-error') if @proposal.is_submission

    File.open("#{Rails.root}/tmp/#{temp_file}", "w:UTF-8") do |io|
      io.write(@input)
    end
    self
  end

  def booklet_content
    @input = pdf_content
    @input
  end

  def to_s
    generate_latex_file unless File.exist?("#{Rails.root}/tmp/#{@temp_file}")

    latex_infile = File.read("#{Rails.root}/tmp/#{@temp_file}")
    "#{@proposal.macros}\n\n\\begin{document}\n\n#{latex_infile}\n"
  end

  def self.format_errors(error)
    error_object = error.cause # RailsLatex::ProcessingError
    error_summary = error_object.log.lines.last(20).join("\n")

    error_output = "<h2 class=\"text-danger\">LaTeX Error Log:</h2>\n\n"
    error_output << "<h4>Last 20 lines:</h4>\n\n"
    error_output << "<pre>\n#{error_summary}\n</pre>\n\n"
    error_output << %q(
      <button class="btn btn-primary mb-4 latex-show-more" type="button"
                     data-bs-toggle="collapse" data-bs-target="#latex-error"
                     aria-expanded="false" aria-controls="latex-error">
              Show full error log
      </button>')
    error_output << "<pre class=\"collapse\" id=\"latex-error\">\n"
    error_output << "#{error_object.log}\n</pre>\n\n"

    error_output << "<h2 class=\"text-danger p-4\">LaTeX Source File:</h2>\n\n"
    error_output << "<pre id=\"latex-source\">\n"

    line_num = 1
    error_object.src.each_line do |line|
      error_output << (line_num.to_s + " #{line}")
      line_num += 1
    end
    error_output << "\n</pre>\n\n"
  end

  private

  def all_proposal_fields
    return 'Proposal data not found!' if proposal.blank?

    proposal_details
    @text
  end

  def proposal_title(proposal, proposal_version = nil)
    if proposal_version
      proposal.no_latex ? delatex(proposal_version&.title) : proposal_version&.title
    else
      proposal.no_latex ? delatex(proposal&.title) : proposal&.title
    end
  end

  def pdf_content
    proposal_organizers
    proposal_locations
    if @proposal_version
      proposal_version_subjects(@proposal_version)
    else
      proposal_subjects
    end
    user_defined_fields
    proposal_bibliography
    proposal_participants

    if @user.staff_member?
      @text << "\\pagebreak"
      proposal_organizing_committee
      @text << "\\pagebreak"
      participant_demographics
    end

    if proposal.files.attached?
      @text, _file_errors = add_proposal_attachments(proposal, @text,
                                                     file_errors)
    end

    @text
  end

  def affil(person)
    return '' if person.blank?

    affil = ""
    affil << " (#{person.affiliation}" if person&.affiliation.present?
    affil << ", #{person.department}" if person&.department.present?
    affil << ")" if person&.affiliation.present?

    delatex(affil)
  end

  def proposal_cover_letter
    return if proposal.cover_letter.blank?

    @text << "\\subsection*{Cover Letter:}\n\n"
    @text << "#{proposal.cover_letter} \\\\ \n"
  end

  def proposal_details
    code = proposal.code.blank? ? '' : "#{proposal.code}: "
    @text = if @proposal_version
              "\\section*{\\centering #{code} #{proposal_title(proposal, @proposal_version)} }\n\n"
            else
              "\\section*{\\centering #{code} #{proposal_title(proposal)} }\n\n"
            end
    proposal_cover_letter
    proposal_participants_count
    proposal_organizers_count
    proposal_lead_organizer
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
    "#{num_participants} confirmed /
     #{proposal.proposal_type&.participant} maximum participants \\\\ \n".squish
  end

  def proposal_participants_count
    @text << "\\subsection*{#{proposal.proposal_type&.name} }\n\n"
    @text << participant_confirmed_count
  end

  def proposal_organizers_count
    confirmed_orgs = (confirmed_organizers&.count || 0) + 1
    @text << "\\noindent #{confirmed_orgs} confirmed /
              #{proposal.max_supporting_organizers + 1}
              maximum organizers\n\n".squish
  end

  def proposal_lead_organizer
    @text << "\\subsection*{Lead Organizer}\n\n"
    @text << "#{proposal.lead_organizer&.fullname} #{affil(proposal.lead_organizer)} \\\\ \n"
    @text << "\\noindent #{delatex(proposal.lead_organizer&.email)}\n\n"
    pdf_content
    @text
  end

  def proposal_organizers
    return if proposal.supporting_organizers&.count&.zero?

    if @text.blank?
      @text = "\\subsection*{Supporting Organizers}\n\n"
    else
      @text << "\\subsection*{Supporting Organizers}\n\n"
    end
    @text << "\\begin{itemize}\n"
    proposal.supporting_organizers.each do |organizer|
      @text << "\\item #{organizer&.person&.fullname}#{affil(organizer&.person)}\n"
    end
    @text << "\\end{itemize}\n\n"
  end

  def proposal_locations
    return if proposal.locations.empty?

    locations = proposal.locations.count > 1 ? 'Locations' : 'Location'
    @text << "\\subsection*{Preferred #{locations}}\n\n"
    @text << "\\begin{enumerate}\n"
    proposal.locations&.each do |location|
      @text << "\\item #{location.name}\n"
    end
    @text << "\\end{enumerate}\n"
  end

  def proposal_subjects
    @text << "\\subsection*{Subject Areas}\n\n"
    @text << "#{proposal.subject&.title} \\\\ \n" if proposal.subject.present?

    ams_subjects = proposal.proposal_ams_subjects&.where(code: 'code1')
    ams_subject1 = AmsSubject.find_by(id: ams_subjects&.first&.ams_subject_id)
    @text << "\\noindent #{ams_subject1&.title} \\\\ \n" if ams_subject1.present?

    ams_subjects = proposal.proposal_ams_subjects&.where(code: 'code2')
    ams_subject2 = AmsSubject.find_by(id: ams_subjects&.first&.ams_subject_id)
    @text << "\\noindent #{ams_subject2&.title} \\\\ \n" if ams_subject2.present?
  end

  def proposal_version_subjects(proposal_version)
    subject_id = proposal_version.subject.to_i
    subject = Subject.find_by(id: subject_id)
    @text << "\\subsection*{Subject Areas}\n\n"
    @text << "#{subject&.title} \\\\ \n" if subject.present?

    ams_subjects(proposal_version)
  end

  def ams_subjects(proposal_version)
    ams_subject1 = AmsSubject.find_by(id: proposal_version.ams_subject_one)
    @text << "\\noindent #{ams_subject1&.title} \\\\ \n" if ams_subject1.present?

    ams_subject2 = AmsSubject.find_by(id: proposal_version.ams_subject_two)
    @text << "\\noindent #{ams_subject2&.title} \\\\ \n" if ams_subject2.present?
  end

  def add_bibliography_heading(bibliography)
    text = "\n\n\\subsection*{Bibliography}\n\n"
    if proposal.no_latex
      text << delatex(bibliography)
    else
      return bibliography if bibliography.include? 'thebibliography'

      text = "\n\\begin{thebibliography}{99}\n\n"
      text << bibliography
      text << "\n\\end{thebibliography}\n\n"
    end

    text
  end

  def proposal_bibliography
    return if proposal.bibliography.blank?

    @text << add_bibliography_heading(proposal.bibliography)
  end

  def user_defined_fields
    @answers = proposal.answers if @answers.blank?

    @answers&.each do |field|
      if field.proposal_field&.fieldable_type == "ProposalFields::PreferredImpossibleDate"
        preferred_impossible_dates(field)
        next
      end

      question = field.proposal_field.statement
      @text << "\\subsection*{#{delatex(question)}}\n\n" if question.present?
      if field.answer.present?
        @text << if @proposal.no_latex
                   "\\noindent #{delatex(field.answer)}\n\n"
                 else
                   "\\noindent #{field.answer}\n\n"
                 end
      end
    end
  end

  def career_heading(career)
    if career.blank?
      "\\noindent \\textbf{Unknown}\n\n"
    else
      "\\noindent \\textbf{#{career}}\n\n"
    end
  end

  def participant_name_and_affil(participant)
    "\\item #{participant.fullname} #{affil(participant)} \n\n"
  end

  def participant_list(career)
    @participants = proposal.get_confirmed_participant(@proposal)
    return '' if @participants.blank?

    text = "\\begin{enumerate}\n\n"
    @participants.each do |participant|
      if participant.academic_status == career
        text << participant_name_and_affil(participant)
      end
    end
    text << "\\end{enumerate}\n\n"
  end

  def participant_careers
    careers = Person.where(id: @proposal.participants
                    .pluck(:person_id)).pluck(:academic_status)
    return [] if careers.blank?

    careers.delete(nil)
    careers.uniq.sort
  end

  def proposal_participants
    return if proposal.participants&.count&.zero?

    @careers = participant_careers
    @text << "\\section*{Participants}\n\n"
    @careers.each do |career|
      @text << career_heading(career)
      @text << participant_list(career)
    end
  end

  def preferred_impossible_dates(field)
    return unless field&.answer

    preferred = JSON.parse(field.answer)&.first(5)
    unless preferred.any?
      @text << "\\subsection*{Preferred dates}\n\n"
      @text << "\\begin{enumerate}\n\n"
      preferred.each do |date|
        @text << "\\item #{date}\n"
      end
      @text << "\\end{enumerate}\n\n"
    end

    impossible = JSON.parse(field.answer)&.last(2)
    return if impossible.any?

    @text << "\\subsection*{Impossible dates}\n\n"
    @text << "\\begin{enumerate}\n\n"
    impossible.each do |date|
      @text << "\\item #{date}\n\n"
    end
    @text << "\\end{enumerate}\n\n"
  end

  def delatex(string)
    return '' if string.blank?

    LatexToPdf.escape_latex(string)
  end

  def proposal_organizing_committee
    @text << "\\section*{\\centering Organizing Committee}\n\n"
    confirmed_organizer
    @text << "\\subsection*{A) Early-Career Researcher}\n\n"
    organizer_early_career
    @text << "\\subsection*{B) Under represented in STEM}"
    organizer_represented_stem
    @text
  end

  def confirmed_organizer
    @confirmed_organizers = proposal.invites.where(status: "confirmed",
                                                   invited_as: "Organizer")
  end

  def organizer_early_career
    @confirmed_organizers&.each do |organizer|
      @person = organizer&.person
      next unless @person.academic_status.present? || @person.academic_status == "Post Doctoral"

      early_career
    end
  end

  def early_career
    @text << if @person.first_phd_year.to_i >= Time.current.year - 10 &&
                @person.first_phd_year.to_i <= Time.current.year
               "\\noindent #{@person.fullname} : Yes\n \n \n"
             else
               "\\noindent #{@person.fullname} : No\n \n \n"
             end
  end

  def organizer_represented_stem
    @confirmed_organizers&.each do |organizer|
      result = organizer.person&.demographic_data&.result
      next if result.nil? || result["stem"] == "Prefer not to answer"

      @text << "\\noindent #{organizer.person.fullname} : #{result['stem']}\n \n \n"
    end
  end

  def participant_demographics
    @text << "\\section*{\\centering Organizing Committee and Participant Demographics}\n\n"
    set_confirmed_invitations
    @text << "\\subsection*{1) Gender}"
    gender_chart
    @text << "\\subsection*{2) Ethnicity}"
    ethnicity_chart
    @text << "\\subsection*{3) Indigenous}\n\n"
    number_of_indigenous
    other_demographic_data
    @text
  end

  def other_demographic_data
    @text << "\\subsection*{4) 2SLGBTQIA+}"
    number_of_community_persons
    @text << "\\subsection*{5) Disability, impairment, or ongoing medical condition}"
    number_of_medical_condition
    @text << "\\subsection*{6) Minority in the country of current affiliation}"
    minority_current_affiliation
    @text << "\\subsection*{7) Under-represented in STEM}"
    number_of_stem_persons
    @text << "\\subsection*{8) Under-represented minority in area}"
    area_minority
  end

  def set_confirmed_invitations
    # due to earlier bugs, there can be more than one confirmed invitation for
    # the same person in a proposal, so use the newest one for each person
    @confirmed_invitations = proposal.invites.where(status: "confirmed")
                                     .order(:id).uniq(&:person_id)

    # add the Lead Organizer, who has no invitation
    @confirmed_invitations << Invite.new(person: @proposal.lead_organizer)
  end

  def number_of_indigenous
    total_count = 0
    actual_count = 0
    @confirmed_invitations&.each do |invite|
      result = invite.person&.demographic_data&.result
      total_count += 1
      actual_count += 1 if result.present? && result["indigenous_person"] == "Yes"
    end
    @text << "\\noindent Number of people self-identified as Indigenous:
              #{actual_count}/#{total_count}\n\n\n".squish
  end

  def ethnicity_chart
    @text << "\\noindent  \\hspace{1cm} \\textbf{\\underline{Ethnicity}} \\hfill \\textbf{\\underline{No.}}\n\n"

    invites_ethnicity_data.each do |key, value|
      @text << if key.include?('Prefer not to answer')
                 "\\noindent  \\hspace{1cm} Prefer not to answer \\hfill #{value}\n\n\n"
               else
                 "\\noindent  \\hspace{1cm} #{key} \\hfill #{value}\n\n\n"
               end
    end
  end

  def gender_chart
    @text << "\\noindent  \\hspace{1cm} \\textbf{\\underline{Gender}} \\hfill \\textbf{\\underline{No.}}\n\n"
    invites_gender_data.each do |key, value|
      @text << "\\noindent  \\hspace{1cm} #{key} \\hfill #{value}\n\n\n"
    end
  end

  def number_of_community_persons
    total_count = 0
    actual_count = 0
    @confirmed_invitations&.each do |invite|
      result = invite.person&.demographic_data&.result
      total_count += 1
      actual_count += 1 if result.present? && result["community"] == "Yes"
    end
    @text << "\\noindent Number of people self-identified as 2SLGBTQIA+: #{actual_count}/#{total_count}\n\n\n"
  end

  def number_of_medical_condition
    total_count = 0
    actual_count = 0
    @confirmed_invitations&.each do |invite|
      result = invite.person&.demographic_data&.result
      total_count += 1
      actual_count += 1 if result.present? && result["disability"] == "Yes"
    end
    @text << "\\noindent Number of people self-identified as a person with a disability,
                 impairment, or ongoing medical condition: #{actual_count}/#{total_count}\n\n\n"
  end

  def minority_current_affiliation
    total_count = 0
    actual_count = 0
    @confirmed_invitations&.each do |invite|
      result = invite.person&.demographic_data&.result
      total_count += 1
      actual_count += 1 if result.present? && result["minorities"] == "Yes"
    end
    @text << "\\noindent Number of people self-identified as a minority
                in the country of current affiliation: #{actual_count}/#{total_count}\n\n\n"
  end

  def number_of_stem_persons
    total_count = 0
    actual_count = 0
    @confirmed_invitations&.each do |invite|
      result = invite.person&.demographic_data&.result
      total_count += 1
      actual_count += 1 if result.present? && result["stem"] == "Yes"
    end
    @text << "\\noindent Number of people self-identified as under-represented in
                STEM: #{actual_count}/#{total_count}\n\n\n"
  end

  def area_minority
    total_count = 0
    actual_count = 0
    @confirmed_invitations&.each do |invite|
      result = invite.person&.demographic_data&.result
      total_count += 1
      actual_count += 1 if result.present? && result["underRepresented"] == "Yes"
    end
    @text << "\\noindent Number of persons in under-represented minority in your area
                (Organizing Committee + Participants): #{actual_count}/#{total_count}\n\n\n"
  end

  def invites_graph_data(param, param2)
    @data = Hash.new(0)
    @confirmed_invitations&.each do |invite|
      @dd = invite.person&.demographic_data
      if @dd.blank?
        @data['Unknown'] += 1
        next
      end

      update_invites_data(param, param2)
    end

    @data&.sort
  end

  def update_invites_data(param, param2)
    @invites_data = [@dd.result[param], @dd.result[param2]].flatten.reject do |s|
      s.blank? || s.eql?("Other")
    end
    @invites_data.each { |c| @data[c] += 1 }
  end

  def invites_ethnicity_data
    @data = invites_graph_data("ethnicity", "ethnicity_other")
  end

  def invites_gender_data
    @data = invites_graph_data("gender", "gender_other")
  end
end
