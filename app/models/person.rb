class Person < ApplicationRecord
  attr_accessor :province, :state, :skip_person_validation

  validates :firstname, :lastname, presence: true, length: { maximum: 35 }
  validates :email, presence: true, uniqueness: true, length: { maximum: 254 }
  belongs_to :user, optional: true
  has_many :proposal_roles, dependent: :destroy
  has_many :proposals, through: :proposal_roles
  has_many :proposal_organizer_roles, -> { lead_organizer }, class_name: 'ProposalRole'
  has_many :lead_organizer_proposals, source: :proposal, through: :proposal_organizer_roles
  has_one :demographic_data, dependent: :destroy
  has_many :reviews, dependent: :destroy
  before_save :downcase_email
  before_save :strip_whitespace

  def downcase_email
    email.downcase!
  end

  def fullname
    "#{firstname} #{lastname}"
  end

  validate :lead_organizer_attributes, if: :lead_organizer?, on: :update
  validate :common_fields, on: :update

  def lead_organizer_attributes
    errors.add('Street 1', "can't be blank") if street_1.blank?
    errors.add('City', "can't be blank") if city.blank?
  end

  def lead_organizer?
    proposal_roles.joins(:role)
                  .where(roles: { name: 'lead_organizer' })
                  .present?
  end

  def region_type
    return "Province" if country == 'Canada'
    return "State" if country == 'United States of America'

    "Region"
  end

  def person_proposal
    proposals.where(status: "submitted")&.first
  end

  def common_fields
    return if skip_person_validation

    person_academic_data
    errors.add('Country', "can't be blank") if country.blank?
    check_academic_status
    return unless country == 'Canada' || country == 'United States of America'

    region_for_countries
  end

  def draft_proposals?
    proposals.where(status: :draft).present?
  end

  private

  def strip_whitespace
    attributes.each do |key, value|
      self[key] = value.strip if value.respond_to?(:strip)
    end
  end

  def person_academic_data
    errors.add('Main Affiliation/Institution', "can't be blank") if affiliation.blank?
    errors.add('Department', "can't be blank") if department.blank?
    errors.add('Academic Status', "can't be blank") if academic_status.blank?
    errors.add('Year of', "PhD can't be blank") if first_phd_year.blank?
  end

  def region_for_countries
    case country
    when "Canada"
      self.region = province if province.present?
    when "United States of America"
      self.region = state if state.present?
    end

    errors.add("Missing data: ", "You must select a #{region_type}") if region.blank?
  end

  def check_academic_status
    return unless academic_status == 'Other' && other_academic_status.blank?

    errors.add(:other_academic_status, "Please indicate your academic status.")
  end
end
