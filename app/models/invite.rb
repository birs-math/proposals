class Invite < ApplicationRecord
  include Logable

  attr_accessor :skip_deadline_validation

  belongs_to :person
  belongs_to :proposal

  before_validation :downcase_email
  before_validation :assign_person, on: :create
  before_save :generate_code
  before_save :strip_whitespace
  before_save :email_downcase

  validates :firstname, :lastname, :email, :invited_as,
            :deadline_date, presence: true
  validates :email,
            format: URI::MailTo::EMAIL_REGEXP
  validate :deadline_not_in_past, :proposal_title
  validate :one_invite_per_person, on: :create
  after_commit :log_activity

  default_scope { order(created_at: :asc) }
  scope :organizer, -> { where(invited_as: 'Organizer') }
  scope :participant, -> { where(invited_as: 'Participant') }
  scope :active, -> { where.not(status: %w[cancelled declined expired]) }
  # Alternative implementation to bypass cache issues
  def self.expired_invitations
    joins(:proposal)
      .where('invites.deadline_date < ? AND invites.status = ? AND proposals.assigned_date IS NOT NULL AND proposals.assigned_date > ?', 
             DateTime.current.beginning_of_day, 0, Date.current)
  end

  # Original scope kept for compatibility but overridden
  scope :expired, -> { expired_invitations }

  enum status: { pending: 0, confirmed: 1, cancelled: 2, declined: 3, expired: 4 }
  enum response: { yes: 0, maybe: 1, no: 2 }

  class << self
    def safe_find(code:)
      return unless code

      invite = not_cancelled.find_by(code: code)

      invite if invite&.code_valid?
    end

    def expire_overdue_invitations
      expired_invites = expired_invitations.includes(:proposal, :person)
      
      expired_invites.find_each do |invite|
        invite.update_columns(
          status: 4, # expired
          expired_at: DateTime.current
        )
      end
      
      expired_invites
    end
  end

  def email_downcase
    email.downcase!
  end

  def generate_code
    self.code = SecureRandom.urlsafe_base64(37) if code.blank?
  end

  def add_person
    return if [firstname, lastname, email].map(&:blank?).any?

    self.person = find_or_create_person
  end

  def assign_person
    if email&.downcase == proposal&.lead_organizer&.email
      errors.add(:base, 'You cannot invite yourself!')
      return
    end

    add_person
  end

  def humanize_invited_as
    invited_as == 'Organizer' ? 'Supporting Organizer' : 'Participant'
  end

  def update_invited_person(affiliation = nil)
    assign_person
    person.affiliation = affiliation if affiliation

    self.firstname = person.firstname
    self.lastname = person.lastname

    person.skip_person_validation = true
    person.save && save
  end

  def code_expired?
    !code_valid?
  end

  def code_valid?
    deadline_date >= DateTime.current.beginning_of_day
  end

  def expired?
    status == 'expired' || (pending? && deadline_date < DateTime.current.beginning_of_day)
  end

  def send_invite_email
    InviteMailer.with(invite: self, lead_organizer_copy: false).invite_email.deliver_later
    InviteMailer.with(invite: self, lead_organizer_copy: true).invite_email.deliver_later
  end

  private

  def downcase_email
    self.email = email.downcase.strip if email.present?
  end

  def proposal_title
    return if proposal.nil? || proposal.title.present?

    errors.add('Proposal Title:', 'Please add a title, and click
        "Save as Draft", before adding people.'.squish)
  end

  def deadline_not_in_past
    return if skip_deadline_validation || deadline_date.nil?

    errors.add('Deadline', "can't be in past") if deadline_date < Date.current
  end

  def one_invite_per_person
    return if proposal.nil? || proposal.invites.where(email: email&.downcase)
                                       .where.not(status: %w[cancelled declined expired]).empty?

    errors.add('Duplicate:', "Same email cannot be used to invite already
                              invited organizers or participants.".squish)
  end

  def strip_whitespace
    attributes.each do |key, value|
      self[key] = value.strip if value.respond_to?(:strip)
    end
  end

  def create_person(fixed_email)
    Person.create(email: fixed_email, firstname: firstname, lastname: lastname)
  rescue ActiveRecord::RecordNotUnique
    errors.add('Email problem:', "#{email} is already used by another
                record, and we are having troubles using it again. Please
                contact birs@birs.ca to report this issue.".squish)
  end

  def find_or_create_person
    return if email.blank?

    fixed_email = email.strip.downcase
    person = Person.find_by(email: fixed_email)
    return person if person.present?

    create_person(fixed_email)
  end

  def log_activity
    return if previous_changes.empty? || User.current.nil?

    audit!(user: User.current)
  end
end
