class Proposal < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_proposals, against: %i[year title status subject_id proposal_type_id],
                                     associated_against: {
                                       people: %i[firstname lastname]
                                     }

  attr_accessor :is_submission

  has_many_attached :files
  has_many :proposal_locations, dependent: :destroy
  has_many :locations, -> { order 'proposal_locations.position' }, through: :proposal_locations
  belongs_to :proposal_type
  has_many :proposal_roles, dependent: :destroy
  has_many :people, through: :proposal_roles
  has_many(:answers, -> { order 'answers.proposal_field_id' }, inverse_of: :proposal, dependent: :destroy)
  has_many :invites, dependent: :destroy
  belongs_to :proposal_form
  has_many :proposal_ams_subjects, dependent: :destroy
  has_many :ams_subjects, through: :proposal_ams_subjects
  belongs_to :subject, optional: true
  has_many :staff_discussions, dependent: :destroy
  has_many :emails, dependent: :destroy

  validates :year, :title, presence: true, if: :is_submission
  validate :subjects, if: :is_submission
  validate :minimum_organizers, if: :is_submission
  validate :preferred_locations, if: :is_submission
  validate :not_before_opening, if: :is_submission
  before_save :create_code, if: :is_submission

  enum status: {
    draft: 0,
    submitted: 1,
    initial_review: 2,
    revision_requested: 3,
    revision_submitted: 4,
    in_progress: 5,
    decision_pending: 6,
    decision_email_sent: 7,
    approved: 8,
    declined: 9
  }

  scope :active_proposals, lambda {
    where(status: 'submitted')
  }

  scope :no_of_participants, lambda { |id, invited_as|
    joins(:invites).where('invites.invited_as = ?
      AND invites.proposal_id = ?', invited_as, id)
  }

  scope :submitted, lambda { |type|
    where(status: 1)
      .joins(:proposal_type).where('name = ?', type)
  }

  def demographics_data
    DemographicData.where(person_id: invites.where(invited_as: 'Participant').pluck(:person_id))
  end

  def create_organizer_role(person, organizer)
    proposal_roles.create!(person: person, role: organizer)
  end

  def lead_organizer
    proposal_roles.joins(:role).find_by('roles.name = ?',
                                        'lead_organizer')&.person
  end

  def the_locations
    locations.pluck(:name).join(', ')
  end

  def list_of_co_organizers
    invites.where(invites: { invited_as: 'Co Organizer' }).map(&:person).map(&:fullname).join(', ')
  end

  def supporting_organizers
    invites.where(invited_as: 'Co Organizer').where(response: %w[yes maybe])
  end

  def participants
    invites.where(invited_as: 'Participant').where(response: %w[yes maybe])
  end

  def participants_career(career)
    person_ids = participants.map(&:person_id)
    Person.where(id: person_ids).where(academic_status: career)
  end

  def self.to_csv
    attributes = ["Code", "Proposal Title", "Proposal Type", "Lead Organizer", "Preffered Locations", "Status",
                  "Updated"]
    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.find_each do |proposal|
        csv << [proposal.code, proposal.title, proposal.proposal_type.name, proposal.lead_organizer.fullname,
                proposal.the_locations, proposal.status, proposal.updated_at.to_date]
      end
    end
  end

  def pdf_file_type(file)
    file.content_type.in?(%w[application/pdf])
  end

  private

  def not_before_opening
    return unless DateTime.current.to_date > proposal_type.closed_date.to_date

    errors.add("Late submission - ", "proposal submissions are not allowed
        because of due date #{proposal_type.closed_date.to_date}".squish)
  end

  def minimum_organizers
    return unless invites.where(status: 'confirmed').count < 1

    errors.add('Supporting Organizers: ', 'At least one supporting organizer
      must confirm their participation by following the link in the email
      that was sent to them.'.squish)
  end

  def subjects
    errors.add('Subject Area:', "please select a subject area") if subject.nil?
    errors.add('AMS Subjects:', 'please select 2 AMS Subjects') unless ams_subjects.pluck(:code).count == 2
  end

  def next_number
    codes = Proposal.submitted(proposal_type.name).pluck(:code)
    last_code = codes.reject { |c| c.to_s.empty? }.max

    return '001' if last_code.blank?

    (last_code[-3..].to_i + 1).to_s.rjust(3, '0')
  end

  def create_code
    return if code.present?

    tc = proposal_type.code || 'xx'
    self.code = year.to_s[-2..] + tc + next_number
  end

  def preferred_locations
    errors.add('Preferred Locations:', "Please select at least one preferred location") if locations.empty?
  end
end
