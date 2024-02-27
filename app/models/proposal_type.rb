class ProposalType < ApplicationRecord
  validates :name, :participant, :co_organizer, :code, :open_date, :closed_date, presence: true
  validates :participant_description, :organizer_description, presence: true
  validates :max_no_of_preferred_dates, :min_no_of_preferred_dates, presence: true
  validates :min_no_of_preferred_dates, :max_no_of_impossible_dates, presence: true
  validates :max_no_of_preferred_dates,
            numericality: { less_than_or_equal_to: 5, greater_than_or_equal_to: 2, only_integer: true }
  validates :min_no_of_preferred_dates,
            numericality: { less_than_or_equal_to: 5, greater_than_or_equal_to: 2, only_integer: true }
  validates :max_no_of_impossible_dates,
            numericality: { less_than_or_equal_to: 2, greater_than_or_equal_to: 0, only_integer: true }
  validates :min_no_of_impossible_dates,
            numericality: { less_than_or_equal_to: 2, greater_than_or_equal_to: 0, only_integer: true }
  validates :code, uniqueness: true
  has_many :proposals, dependent: :destroy
  has_many :proposal_forms, dependent: :destroy
  has_many :proposal_type_locations, dependent: :destroy
  has_many :locations, through: :proposal_type_locations
  validate :not_closed_date_greater
  validate :max_preferred_greater_than_min_preferred
  validate :max_impossible_greater_than_min_impossible

  scope :active_forms, -> { joins(:proposal_forms).where('proposal_forms.status =?', 1).distinct }

  FIVE_DAY_WORKSHOP = '5-Day Workshop'.freeze
  SUMMER_SCHOOL = 'Summer School'.freeze
  FIVE_DAY_WORKSHOP_AND_SUMMER_SCHOOL = "#{FIVE_DAY_WORKSHOP} and #{SUMMER_SCHOOL}".freeze

  def active_form
    proposal_forms.where('proposal_forms.status =?', 1).last
  end

  def not_lead_organizer?(person_id)
    proposals.joins(proposal_roles: :role)
             .where("proposal_roles.person_id =?", person_id)
             .where('roles.name =?', 'lead_organizer').empty?
  end

  # rubocop:disable Metrics/AbcSize
  def not_closed_date_greater
    return if open_date.nil? || closed_date.nil?

    if open_date.to_date > closed_date.to_date
      errors.add("Open Date ", "#{open_date.to_date} - cannot be greater than
          Closed Date #{closed_date.to_date}".squish)
    elsif open_date.to_date == closed_date.to_date
      errors.add("Open Date ", "#{open_date.to_date} - cannot be same as
          Closed Date #{closed_date.to_date}".squish)
    end
  end

  def max_preferred_greater_than_min_preferred
    return unless min_no_of_preferred_dates > max_no_of_preferred_dates

    errors.add("Minimum number",
               " of preferred dates can not be greater than maximum number of preferred dates".squish)
  end

  def max_impossible_greater_than_min_impossible
    return unless min_no_of_impossible_dates > max_no_of_impossible_dates

    errors.add("Minimum number",
               " of impossible dates can not be greater than maximum number of impossible dates".squish)
  end
  # rubocop:enable Metrics/AbcSize
end
