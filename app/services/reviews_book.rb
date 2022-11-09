class ReviewsBook
  attr_reader :proposals_id, :text, :temp_file, :errors, :year, :content_type, :table

  include LatexAttachments

  def initialize(proposals_id, temp_file, content_type, table)
    @proposals_id = proposals_id
    @text = ""
    @temp_file = temp_file
    @errors = []
    @content_type = content_type
    @table = table
  end

  def generate_booklet
    @number = 0

    @proposals = Proposal.where(id: @proposals_id)
    @year = @proposals&.first&.year || (Date.current.year + 2)
    booklet_title_page(year)

    if @table == "toc"
      reviews_with_contents
    else
      reviews_without_contents
    end

    File.open("#{Rails.root}/tmp/#{@temp_file}", "w:UTF-8") do |io|
      io.write(@text)
    end
  end

  private

  def reviews_with_contents
    @text << "\\tableofcontents"
    subjects_with_proposals = @proposals.sort_by { |p| p.subject.title }.group_by(&:subject_id)
    subjects_with_proposals.each do |subject|
      @subject = Subject.find_by(id: subject.first)
      check_subject
      @proposals_objects = subject.last
      subject_proposals
    end
  end

  def reviews_without_contents
    @proposals.each do |proposal|
      @proposal = proposal
      pdf_contents
    end
  end

  def check_subject
    return if @subject.blank?

    @number += 1
    @text << "\\addcontentsline{toc}{chapter}{ \\large{#{@number}. #{@subject&.title}}}\n\n"
  end

  def subject_proposals
    @proposals_objects&.sort_by(&:code)&.each do |proposal|
      @proposal = proposal
      @code = proposal.code.blank? ? '' : "#{proposal.code}: "
      @text << "\\addcontentsline{toc}{section}{ #{@code} #{delatex(proposal&.title)}}\n\n"
      pdf_contents
    end
  end

  def pdf_contents
    organizers_list
    average_grade
  end

  def proposal_title(proposal)
    proposal.no_latex ? delatex(proposal&.title) : proposal&.title
  end

  def delatex(string)
    return '' if string.blank?

    LatexToPdf.escape_latex(string)
  end

  def affil(person)
    return '' if person.blank?

    affil = ""
    affil << " (#{person.affiliation}" if person&.affiliation.present?
    affil << ", #{person.department}" if person&.department.present?
    affil << ")" if person&.affiliation.present?

    delatex(affil)
  end

  def booklet_title_page(year)
    @text = "\n\\thispagestyle{empty}\n"
    @text << "\\begin{center}\n"
    @text << "\\includegraphics[width=4in]{birs_logo.jpg}\\\\[30pt]\n"
    @text << "{\\writeblue\\titlefont Banff International\\\\[10pt]
                Research Station\\\\[0.5in]\n"
    @text << "#{year} Proposal Reviews}\n"
    @text << "\\end{center}\n\n"
    @text << "\\newpage\n\n"
  end

  def organizers_list
    @text << "\\pagebreak\n\n"
    @text << "\\section*{\\centering #{@code} #{delatex(proposal_title(@proposal))} }\n\n"
    @text << "\\subsection*{Organizers}\n\n"
    @text << "\\textbf{#{@proposal.lead_organizer&.fullname} #{affil(@proposal.lead_organizer)}} \\\\ \n"
    confirmed_organizers
  end

  def confirmed_organizers
    @proposal.supporting_organizers.each do |organizer|
      @text << "\\noindent #{organizer&.person&.fullname}#{affil(organizer&.person)}\n\n\n"
    end
  end

  def average_grade
    scientific_grade_reviews if @content_type == "both" || @content_type == "scientific"
    edi_grade_reviews if @content_type == "both" || @content_type == "edi"
  end

  def scientific_grade_reviews
    reviews = @proposal.reviews&.where(is_quick: false)
    score = reviews_scores(reviews)
    scientific_grade = 0
    scientific_grade = (score / @reviewers_count.to_f).round(2) unless @reviewers_count.eql?(0)
    @text << "\\subsection*{Overall Average Scientific Grade: #{scientific_grade}}\n\n\n"
    graded_reviews
    proposal_review(reviews)
  end

  def edi_grade_reviews
    reviews = @proposal.reviews&.where(is_quick: true)
    score = reviews_scores(reviews)
    edi_grade = 0
    edi_grade = (score / @reviewers_count.to_f).round(2) unless @reviewers_count.eql?(0)
    @text << "\\subsection*{Overall Average EDI Grade: #{edi_grade}}\n\n\n"
    graded_reviews
    proposal_review(reviews)
  end

  def reviews_scores(reviews)
    scores = reviews.map(&:score)
    scores&.compact!
    @reviewers_count = 0
    @reviewers_count = scores&.count
    score = 0
    scores.each do |s|
      score += s
    end
    score
  end

  def graded_reviews
    @text << "\\noindent Total number of graded reviews: #{@reviewers_count}\n\n\n"
  end

  def proposal_review(reviews)
    @table = 0
    reviews.each do |review|
      next if review.score.nil? || review.score.eql?(0)

      @table += 1
      @text << "\\subsection*{#{@table}. Grade: #{review.score} (#{review.reviewer_name})}\n\n"
      review_comments(review) if review.file_ids.present?
    end
  end

  def review_comments(review)
    @text << "\\subsection*{Reviews:}\n\n\n"
    return unless review.files.attached?

    latex, file_errors = add_review_attachments(review, @text, @proposal,
                                                @errors)
    @errors = file_errors if file_errors.present?
    @text = latex if latex.present?
  end
end
