class Invite < ApplicationRecord
  before_validation :assign_person
  validates :firstname, :lastname, :email, :invited_as, :deadline_date, presence: true
  validate :proposal_title
  enum status: { pending: 0, confirmed: 1, cancelled: 2 }
  enum response: { yes: 0, maybe: 1, no: 2 }

  belongs_to :person
  belongs_to :proposal

  before_save :generate_code
  validate :deadline_not_in_past

  # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :email, uniqueness: { scope: :proposal_id,
                                  message: "Same email cannot be used to invite already
                                  invited organizers or participants.".squish,
                                  conditions: -> { where.not(response: :no) } }
  # rubocop:enable Rails/UniqueValidationWithoutIndex

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  def generate_code
    self.code = SecureRandom.urlsafe_base64(37) if code.blank?
  end

  def proposal_title
    return if proposal.nil?

    return if proposal.title.present?

    errors.add('Proposal Title:', 'Please add a title, and click
        "Save as Draft", before adding people.'.squish)
  end

  def deadline_not_in_past
    return if deadline_date.nil?

    errors.add('Deadline', "can't be in past") if deadline_date < Date.current
  end

  def invited_as?
    invited_as == 'Co Organizer' ? 'Supporting Organizer' : 'Participant'
  end

  def assign_person
    errors.add(:base, 'You cannot invite yourself!') if email == proposal&.lead_organizer&.email

    add_person
  end

  def add_person
    return if firstname.blank? || lastname.blank? || email.blank?

    person = Person.find_by(email: email)
    person ||= Person.create(email: email, firstname: firstname, lastname: lastname)

    self.person = person
  end
end
