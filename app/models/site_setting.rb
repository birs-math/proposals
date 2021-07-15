class SiteSetting < ApplicationRecord
  validates :guideline, presence: true
end
