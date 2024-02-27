class Review < ApplicationRecord
  belongs_to :person
  belongs_to :proposal
  # isQuick is ture means it's EDI review otherwise scientific
  has_many_attached :files

  # TODO: change how EDI and Scientific reviews are stored
  scope :edi, -> { where(is_quick: true) }
  scope :scientific, -> { where(is_quick: false) }

  default_scope { order(version: :desc) }

  def file_type(file)
    file&.content_type&.in?(["application/pdf", "text/plain"])
  end
end
