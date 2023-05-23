# Right now only used for storing source latex file when ProposalBookletJob encounters rendering error
class LatexToPdfLog < ApplicationRecord
  before_create :identify_mime_type

  private

  def identify_mime_type
    self.mime_type = MiniMime.lookup_by_filename(file_name).content_type if mime_type.blank?
  end
end
