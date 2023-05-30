module SubjectsHelper
  def subjects_area
    Subject.order(:title).pluck(:title, :id)
  end

  def ams_subjects_code
    AmsSubject.order(:title).pluck(:title, :id)
  end

  def ams_subject_title(ams_subject)
    ams_subject.title.remove(ams_subject.title.split.first)
  end
end
