class Location < ApplicationRecord
  validates :name, :city, :country, :code, presence: true
  validates :code, uniqueness: true
  has_many :proposal_type_locations, dependent: :destroy
  has_many :proposal_types, through: :proposal_type_locations
  has_many :proposal_locations, dependent: :destroy
  has_many :proposals, through: :proposal_locations
  has_many :proposal_fields
  has_many :schedule_runs
  validate :date_rules

  scope :birs, -> { find_by(code: 'BIRS') }

  def date_rules
    return if start_date.nil? || end_date.nil?

    check_greater_date
    check_equal_date
    check_valid_date_range
    check_valid_exclude_dates
  end

  def num_weeks
    return 0 if start_date.blank? || end_date.blank?

    weeks = (end_date.to_time - start_date.to_time).seconds.in_weeks.round.abs
    return weeks if exclude_dates.blank?

    remove_excluded_dates(weeks)
  end

  def remove_excluded_dates(weeks)
    exclude_dates.delete("")
    weeks - exclude_dates.count
  end

  def excluded_dates
    exclude_dates.map { |date_string| Date.parse(date_string) }
  end

  private

  def check_greater_date
    return unless start_date > end_date

    errors.add("Start Date", "#{start_date} - cannot be greater than
                              End Date #{end_date}".squish)
  end

  def check_equal_date
    return unless start_date == end_date

    errors.add("Start Date", "#{start_date} - cannot be same as
                              End Date #{end_date}".squish)
  end

  def check_valid_date_range
    # BIRS 5 Day workshops begin on Sundays, end on Fridays
    errors.add("Start Date", "must be a Sunday.") unless start_date.sunday?
    errors.add("End Date", "must be a Friday.") unless end_date.friday?
  end

  def parse_exclude_date(date_string)
    field = 'Exclude Dates'
    ds = date_string
    date = Date.parse(ds)
    errors.add(field, "#{ds} must be after Start Date") if date < start_date
    errors.add(field, "#{ds} must be before End Date") if date > end_date
  rescue Date::Error
    errors.add(field, "#{ds} is not a valid date string.")
  end

  def check_valid_exclude_dates
    return if exclude_dates.blank?

    exclude_dates.each do |date_string|
      next if date_string.blank?

      parse_exclude_date(date_string)
    end
  end
end
