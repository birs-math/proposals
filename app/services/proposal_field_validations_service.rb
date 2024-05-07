class ProposalFieldValidationsService
  VALIDATION_TYPES = {
    'mandatory' => :mandatory,
    'less than (integer matcher)' => :less_than_integer,
    'less than (float matcher)' => :less_than_float,
    'greater than (integer matcher)' => :greater_than_integer,
    'greater than (float matcher)' => :greater_than_float,
    'equal (string matcher)' => :equal_string,
    'equal (integer matcher)' => :equal_integer,
    'equal (float matcher)' => :equal_float,
    'words limit' => :words_limit,
    '5-day workshop preferred/Impossible dates' => :preferred_impossible_dates
  }.freeze

  attr_reader :proposal, :field, :value

  def initialize(field, proposal, value)
    @proposal = proposal
    @field = field
    @value = value
    @errors = []
  end

  def validations
    return unless proposal

    check_validations(field.validations)
    @errors
  end

  def check_validations(validations)
    validations.each do |val|
      send(VALIDATION_TYPES[val.validation_type], val)
    end
  end

  def preferred_impossible_dates(val)
    if value.nil?
      @errors << dates_error_message("You have to choose atleast #{proposal.proposal_type.min_no_of_preferred_dates} preferred dates", val)
      @errors << dates_error_message("You have to choose atleast #{proposal.proposal_type.min_no_of_impossible_dates} impossible dates", val)
      return
    end

    preferred_dates, impossible_dates = parse_and_filter_dates
    uniq_dates = (preferred_dates + impossible_dates).uniq

    @errors << dates_error_message("You can't select the same date twice", val) unless uniq_dates.count == (preferred_dates + impossible_dates).count

    check_preferred_dates_count(preferred_dates, val)
    check_impossible_dates_count(impossible_dates, val)
  end

  def error_message(validation)
    validation.error_message.prepend("Step 2 ##{validation.proposal_field.position} ")
  end

  def dates_error_message(message, validation)
    message.prepend("Step 2 ##{validation.proposal_field.position} #{message}")
  end

  private

  def parse_and_filter_dates
    preferred, impossible = if value.is_a?(Array)
                              [value.first(5), value.last(2)]
                            else
                              [JSON.parse(value)&.first(5), JSON.parse(value)&.last(2)]
                            end

    preferred_dates = preferred.reject { |date| date == '' }
    impossible_dates = impossible.reject { |date| date == '' }

    [preferred_dates, impossible_dates]
  end

  def check_preferred_dates_count(preferred_dates, val)
    if preferred_dates.count > proposal.proposal_type.max_no_of_preferred_dates
      @errors << dates_error_message("You can choose maximum #{proposal.proposal_type.max_no_of_preferred_dates} preferred dates", val)
    end

    if preferred_dates.count < proposal.proposal_type.min_no_of_preferred_dates
      @errors << dates_error_message("You have to choose at least #{proposal.proposal_type.min_no_of_preferred_dates} preferred dates", val)
    end
  end

  def check_impossible_dates_count(impossible_dates, val)
    if impossible_dates.count > proposal.proposal_type.max_no_of_impossible_dates
      @errors << dates_error_message("You can choose maximum #{proposal.proposal_type.max_no_of_impossible_dates} impossible dates", val)
    end

    if impossible_dates.count < proposal.proposal_type.min_no_of_impossible_dates
      @errors << dates_error_message("You have to choose at least #{proposal.proposal_type.min_no_of_impossible_dates} impossible dates", val)
    end
  end

  def mandatory(val)
    @errors << error_message(val) if value.blank?
  end

  def less_than_integer(val)
    @errors << error_message(val) unless value.to_i < val.value.to_i
  end

  def less_than_float(val)
    @errors << error_message(val) unless value.to_f < val.value.to_f
  end

  def greater_than_integer(val)
    @errors << error_message(val) unless value.to_i > val.value.to_i
  end

  def greater_than_float(val)
    @errors << error_message(val) unless value.to_f > val.value.to_f
  end

  def equal_string(val)
    @errors << error_message(val) unless value == val.value
  end

  def equal_integer(val)
    @errors << error_message(val) unless value.to_i == val.value.to_i
  end

  def equal_float(val)
    @errors << error_message(val) unless value.to_f == val.value.to_f
  end

  def words_limit(val)
    texcount = `echo "#{value}" | texcount -total -`
    word_count = texcount.match(/Words in text: (\d+)/)[1]
    @errors << error_message(val) unless word_count.to_i <= val.value.to_i
  end
end
