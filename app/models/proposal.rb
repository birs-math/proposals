class Proposal < ApplicationRecord
  include AASM
  include PgSearch::Model
  include Logable

  attr_accessor :is_submission, :allow_late_submission

  has_many_attached :files
  has_many :proposal_locations, dependent: :destroy
  has_many :locations, -> { includes(:proposal_locations).order('proposal_locations.position') },
           through: :proposal_locations
  belongs_to :proposal_type
  has_many :proposal_roles, dependent: :destroy
  has_many :people, through: :proposal_roles
  has_one :lead_organizer_proposal_role, -> { lead_organizer }, class_name: 'ProposalRole'
  has_one :lead_organizer, through: :lead_organizer_proposal_role, source: :person
  has_many(:answers, -> { order 'answers.proposal_field_id' },
           inverse_of: :proposal, dependent: :destroy)
  has_many :invites, dependent: :destroy
  belongs_to :proposal_form
  has_many :proposal_ams_subjects, dependent: :destroy
  has_many :ams_subjects, through: :proposal_ams_subjects
  belongs_to :subject, optional: true
  has_many :staff_discussions, dependent: :destroy
  has_many :emails, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :proposal_versions, dependent: :destroy
  has_many :feedbacks, dependent: :destroy

  before_save :strip_whitespace
  before_save :create_code, if: :is_submission
  after_commit :log_activity

  validates :year, :title, presence: true, if: :is_submission
  validate :subjects, if: :is_submission
  validate :minimum_organizers, if: :is_submission
  validate :preferred_locations, if: :is_submission
  validate :not_before_opening, if: :is_submission
  validate :cover_letter_field, if: :is_submission

  pg_search_scope :search_proposals, against: %i[title code],
                                     associated_against: {
                                       people: %i[firstname lastname]
                                     }, using: {
                                       tsearch: {
                                         prefix: true
                                       }
                                     }

  pg_search_scope :search_proposal_type, against: %i[proposal_type_id]
  pg_search_scope :search_proposal_status, against: %i[status]
  pg_search_scope :search_proposal_year, against: %i[year]
  pg_search_scope :search_proposal_location, against: %i[assigned_location_id]
  pg_search_scope :search_proposal_outcome, against: %i[outcome]
  belongs_to :assigned_location, class_name: 'Location', optional: true

  enum status: {
    draft: 0,
    submitted: 1,
    initial_review: 2,
    revision_requested_before_review: 3,
    revision_submitted: 4,
    in_progress: 5,
    decision_pending: 6,
    decision_email_sent: 7,
    approved: 8,
    declined: 9,
    revision_requested_after_review: 10,
    revision_submitted_spc: 11,
    in_progress_spc: 12,
    shortlisted: 13
  }

  aasm column: :status, enum: true do
    state :draft, initial: true
    state :submitted
    state :initial_review
    state :revision_requested_before_review
    state :revision_requested_after_review
    state :revision_submitted
    state :revision_submitted_spc
    state :in_progress
    state :in_progress_spc
    state :decision_pending
    state :decision_email_sent
    state :shortlisted

    event :active do
      transitions from: :draft, to: :submitted
    end

    event :review do
      transitions from: :submitted, to: :initial_review
    end

    event :progress do
      transitions from: %i[initial_review revision_submitted], to: :in_progress
    end

    event :pending do
      transitions from: %i[in_progress in_progress_spc revision_submitted revision_submitted_spc], to: :decision_pending
    end

    event :requested do
      transitions from: %i[initial_review decision_pending revision_submitted], to: :revision_requested_before_review
    end

    event :requested_spc do
      transitions from: %i[initial_review decision_pending revision_submitted_spc shortlisted],
                  to: :revision_requested_after_review
    end

    event :revision do
      transitions from: :revision_requested_before_review, to: :revision_submitted
    end

    event :revision_spc do
      transitions from: :revision_requested_after_review, to: :revision_submitted_spc
    end

    event :decision do
      transitions from: %i[decision_pending shortlisted], to: :decision_email_sent
    end
    event :progress_spc do
      transitions from: :revision_submitted_spc, to: :in_progress_spc
    end
  end

  scope :active_proposals, lambda {
    where(status: 'submitted')
  }

  scope :no_of_participants, lambda { |id, invited_as|
    joins(:invites).where('invites.invited_as = ?
      AND invites.proposal_id = ?', invited_as, id)
  }

  scope :submitted_type, lambda { |type|
    joins(:proposal_type).where(proposal_type: { name: type })
  }

  def to_param
    code || id.to_s
  end

  def self.find(param)
    return if param.blank?

    param.to_s.match?(/\D/) ? find_by(code: param) : super
  end

  def editable?
    draft? || revision_requested_before_review? || revision_requested_after_review?
  end

  def demographics_data
    @demographics_data ||= DemographicData.where(person_id: participant_invites.pluck(:person_id))
  end

  def create_organizer_role(person, organizer)
    proposal_roles.create!(person: person, role: organizer)
  end

  def location_names
    locations.pluck(:name).join(', ')
  end

  def supporting_organizers
    Person.where(id: supporting_organizer_invites.pluck(:person_id))
  end

  def participants
    Person.where(id: participant_invites.pluck(:person_id))
  end

  def supporting_organizer_invites
    invites.confirmed.organizer
  end

  def participant_invites
    invites.confirmed.participant
  end

  def self.supporting_organizer_fullnames(proposal)
    proposal&.supporting_organizer_invites&.map { |org| "#{org.firstname} #{org.lastname}" }&.join(', ')
  end

  def self.participants_fullnames(proposal)
    proposal&.participant_invites&.map { |org| "#{org.firstname} #{org.lastname}" }&.join(', ')
  end

  def self.participants_emails(proposal)
    proposal&.participant_invites&.map(&:email)&.join(', ')
  end

  def self.supporting_organizer_emails(proposal)
    proposal&.supporting_organizer_invites&.map(&:email)&.join(', ')
  end

  def self.to_csv(proposals)
    CSV.generate(headers: true) do |csv|
      csv << HEADERS
      proposals.find_each do |proposal|
        csv << each_row(proposal)
      end
    end
  end

  HEADERS = ["Code", "Proposal Title", "Proposal Type", "Preferred Locations", "Assigned Location",
             "Status", "Outcome", "Updated", "Submitted to EditFlow", "Subject Area", "Lead Organizer",
             "Lead Organizer Email", "Supporting Organizers", " Supporting Organizers Email",
             "Participants Name", "Participants Emails",
             "Max No of Preferred Dates", "Min No of Preferred Dates", "Preferred Dates",
             "Max No of Impossible Dates", "Min No of Impossible Dates", "Impossible Dates"].freeze

  def self.each_row(proposal)
    [proposal&.code, proposal&.title, proposal&.proposal_type&.name,
     proposal&.location_names, proposal&.assigned_location&.name, proposal&.status, proposal&.outcome,
     proposal&.updated_at&.to_date, proposal&.edit_flow&.to_date,
     proposal&.subject&.title, proposal&.lead_organizer&.fullname,
     proposal&.lead_organizer&.email, supporting_organizer_fullnames(proposal),
     supporting_organizer_emails(proposal), participants_fullnames(proposal), participants_emails(proposal),
     proposal&.proposal_type&.max_no_of_preferred_dates, proposal&.proposal_type&.min_no_of_preferred_dates,
     proposal&.preferred_dates, proposal&.proposal_type&.max_no_of_impossible_dates,
     proposal&.proposal_type&.min_no_of_impossible_dates, proposal&.impossible_dates]
  end

  def pdf_file_type(file)
    file.content_type.in?(%w[application/pdf])
  end

  def macros
    preamble || ''
  end

  def max_supporting_organizers
    proposal_type&.co_organizer
  end

  def max_participants
    proposal_type&.participant
  end

  def max_virtual_participants
    300 # temp until max_virtual setting is added
  end

  def max_total_participants
    max_participants + max_virtual_participants
  end

  def preferred_dates
    answer = preferred_impossible_field
    return '' if answer.blank?

    (0..4).each_with_object([]) do |i, preferred_dates|
      next if answer[i].blank?

      date = answer[i].split(' to ')
      preferred_dates << Date.strptime(date.first.strip, '%m/%d/%Y')
      preferred_dates << Date.strptime(date.last, '%m/%d/%Y')
    end
  end

  def impossible_dates
    answer = preferred_impossible_field
    (5..6).each_with_object([]) do |i, impossible_dates|
      next if answer[i].blank?

      date = answer[i].split(' to ')
      impossible_dates << Date.strptime(date.first.strip, '%m/%d/%Y')
      impossible_dates << Date.strptime(date.last, '%m/%d/%Y')
    end
  end

  def birs_emails
    emails = [['birs-director@birs.ca', 'birs-director@birs.ca'], ['birs@birs.ca', 'birs@birs.ca']]
    emails.map { |disp, _value| disp }
  end

  # This method calculates event start_date for Workshops integration,
  # schedules assign applied_date but manual exports don't, ideally it should be calculated in dedicated serializer
  def safe_applied_date
    return @safe_applied_date if defined?(@safe_applied_date)

    @safe_applied_date =
      begin
        return applied_date if applied_date.present?

        proposal_or_current_year = year.to_s || Time.zone.now.year.to_s
        Date.strptime(proposal_or_current_year, "%Y")
      end
  end

  def safe_assigned_location
    return assigned_location if assigned_location.present?

    Location.birs
  end

  private

  def preferred_impossible_field
    proposal_fields = answers.joins(:proposal_field).where("proposal_fields.fieldable_type =?",
                                                           "ProposalFields::PreferredImpossibleDate")

    return [] if proposal_fields.blank? || proposal_fields.first.answer.nil?

    JSON.parse(proposal_fields.first.answer)
  end

  def not_before_opening
    return if draft? || revision_requested_before_review? || revision_requested_after_review? || allow_late_submission

    return unless DateTime.current.to_date > proposal_type.closed_date.to_date

    errors.add("Late submission - ", "proposal submissions closed on
               #{proposal_type.closed_date.to_date}".squish)
  end

  def minimum_organizers
    return unless invites.where(status: 'confirmed').count < 1

    errors.add('Supporting Organizers: ', 'At least one supporting organizer
               must confirm their participation by following the link in the
               email that was sent to them.'.squish)
  end

  def subjects
    errors.add('Subject Area:', "please select a subject area") if subject.nil?
    errors.add('AMS Subjects:', 'please select 2 AMS Subjects') unless ams_subjects.pluck(:code).count == 2
  end

  def cover_letter_field
    return unless revision_requested_after_review?

    errors.add('Cover Letter:', "shouldn't be empty.") if cover_letter.blank?
  end

  def next_number
    tc = proposal_type.code || 'xx'
    year_code = year.to_s[-2..]

    # Get all existing codes for this year and type, sorted numerically
    existing_codes = Proposal.where("code LIKE ?", "#{year_code}#{tc}%")
                             .where.not(id: id) # Exclude current record if updating
                             .pluck(:code)
                             .map { |code| code[-3..].to_i } # Extract numeric part
                             .sort

    # Find the first gap in the sequence, or the next number after the highest
    next_number = 1
    existing_codes.each do |existing_num|
      break if next_number < existing_num

      next_number = existing_num + 1
    end

    next_number.to_s.rjust(3, '0')
  end

  def create_code
    return if code.present?

    max_attempts = 10
    attempt = 0

    begin
      attempt += 1

      Proposal.transaction do
        tc = proposal_type.code || 'xx'
        year_code = year.to_s[-2..]
        proposed_code = year_code + tc + next_number

        # Use a locked query to check for existence within the transaction
        if Proposal.lock.where(code: proposed_code).where.not(id: id).exists?
          raise ActiveRecord::RecordNotUnique, "Code #{proposed_code} already exists"
        end

        self.code = proposed_code
      end

      Rails.logger.info "Successfully generated code: #{code} after #{attempt} attempt(s)"
    rescue ActiveRecord::RecordNotUnique => e
      Rails.logger.warn "Code generation attempt #{attempt} failed: #{e.message}"

      if attempt < max_attempts
        # Exponential backoff with jitter to reduce collision probability
        sleep_time = (0.1 * (2**(attempt - 1))) + (rand * 0.1)
        Rails.logger.info "Retrying code generation in #{sleep_time.round(3)} seconds..."
        sleep(sleep_time)
        retry
      else
        Rails.logger.error "Failed to generate unique code after #{max_attempts} attempts for proposal #{id}"

        # Instead of raising an exception, add a validation error
        errors.add(:code, "Unable to generate unique code after #{max_attempts} attempts. Please try again.")
        raise ActiveRecord::RecordInvalid, "Code generation failed"
      end
    rescue StandardError => e
      Rails.logger.error "Unexpected error during code generation: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise
    end
  end

  def preferred_locations
    return unless locations.empty?

    errors.add('Preferred Locations:', "Please select at least one preferred
                 location".squish)
  end

  def strip_whitespace
    attributes.each do |key, value|
      self[key] = value.strip if value.respond_to?(:strip)
    end
  end

  def log_activity
    return if previous_changes.empty? || User.current.nil?

    audit!(user: User.current)
  end
end
