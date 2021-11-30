class Invite < ApplicationRecord
  attr_accessor :skip_deadline_validation

  belongs_to :person
  belongs_to :proposal

  before_validation :downcase_email, :assign_person
  before_save :generate_code
  before_save :strip_whitespace
  before_save :email_downcase

  validates :firstname, :lastname, :email, :invited_as,
            :deadline_date, :person_id, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :deadline_not_in_past, :proposal_title
  validate :one_invite_per_person, on: :create

  enum status: { pending: 0, confirmed: 1, cancelled: 2 }
  enum response: { yes: 0, maybe: 1, no: 2 }

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

  def invited_as?
    invited_as == 'Organizer' ? 'Supporting Organizer' : 'Participant'
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
    return if proposal.nil? || proposal.invites.where(email: email.downcase)
                                       .where.not(status: 'cancelled').empty?

    errors.add('Duplicate:', "Same email cannot be used to invite already
                              invited organizers or participants.".squish)
  end

  def strip_whitespace
    attributes.each do |key, value|
      self[key] = value.strip if value.respond_to?(:strip)
    end
  end

  def create_person(email)
    Person.create(email: email, firstname: firstname, lastname: lastname)

  rescue ActiveRecord::RecordNotUnique
    errors.add('Email problem:', "#{email} is already used by another
                record, and we are having troubles using it again. Please
                contact birs@birs.ca to report this issue.".squish)
  end

  def find_or_create_person
    return if self.email.blank?

    email = self.email.strip.downcase
    person = Person.find_by(email: email)
    create_person(email) if person.blank?
  end
end
