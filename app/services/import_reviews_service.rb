class ImportReviewsService
  attr_reader :proposal, :errors

  def initialize(proposal)
    @proposal = proposal
    @errors = []
  end

  def proposal_reviews
    edit_flow_query = EditFlowService.new(@proposal).mutation

    response = RestClient.post ENV.fetch('EDITFLOW_API_URL', nil),
                               { query: edit_flow_query },
                               { x_editflow_api_token: ENV.fetch('EDITFLOW_API_TOKEN', nil) }

    if response.body.include?("errors")
      display_errors(response)
    else
      review_version = get_response_body(response)
      store_proposal_reviews(review_version) if review_version.present?
    end
  end

  def display_errors(response)
    Rails.logger.info { "\n\nError sending #{@proposal.code}: #{response.body}\n\n" }
    @errors << "Error sending #{@proposal.code}: #{response.body}"
    nil
  end

  def get_response_body(response)
    response_body = JSON.parse(response.body)
    article = response_body["data"]["article"]
    return nil unless article

    review_version = article["reviewVersionLatest"]["number"]
    check_review_version(review_version)
    @reviews = article["reviewVersionLatest"]["reviews"]
    review_version
  end

  def check_review_version(review_version)
    return unless @proposal.reviews&.pluck(:version)&.uniq&.include? review_version

    reviews = @proposal.reviews.where(version: review_version)
    reviews.destroy_all
  end

  def store_proposal_reviews(review_version)
    if @reviews.present?
      @reviews.each do |review|
        reviewer_name = review["reviewer"]["nameFull"]
        is_quick = review["isQuick"]
        @score = review["score"]

        @review = Review.new(reviewer_name: reviewer_name, is_quick: is_quick, score: @score,
                             proposal_id: @proposal.id, person_id: @proposal.lead_organizer&.id,
                             version: review_version)
        @review.save
        review_file(review)
      end
    else
      "No_review_found"
    end
  end

  def review_file(review)
    @review_files = []
    @review_dates = []
    review["reports"]&.each do |report|
      next if report["fileID"].blank?

      review_file_url(report["fileID"])
      @review_files << report["fileID"]
      date = Time.zone.at(report["dateReported"])
      @review_dates << date
    end
    @review.update(file_ids: @review_files.join(', '), review_date: @review_dates.join(', '))
  end

  def review_file_url(file_id)
    file_url_query = EditFlowService.new(@proposal).file_url(file_id)
    response = RestClient.post ENV.fetch('EDITFLOW_API_URL', nil),
                               { query: file_url_query },
                               { x_editflow_api_token: ENV.fetch('EDITFLOW_API_TOKEN', nil) }

    if response.body.include?("errors")
      display_errors(response)
    else
      find_store_review_file(response)
    end
  end

  def find_store_review_file(response)
    response_body = JSON.parse(response.body)
    file_url = response_body["data"]["fileURL"]
    url = file_url["url"]
    @file = URI.parse(url).open
    @filename = File.basename(url)
    @review.files.attach(io: @file, filename: @filename)
  end
end
