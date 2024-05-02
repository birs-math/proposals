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

  def preferred_impossible_dates(_val)
    if value.nil?
      @errors << "You have to choose atleast #{proposal.proposal_type.min_no_of_preferred_dates} preferred dates"
      @errors << "You have to choose atleast #{proposal.proposal_type.min_no_of_impossible_dates} impossible dates"
      return
    end
    preferred = JSON.parse(value)&.first(5)
    impossible = JSON.parse(value)&.last(2)
    preferred_dates = preferred.reject { |date| date == '' }
    impossible_dates = impossible.reject { |date| date == '' }
    uniq_dates = JSON.parse(value).reject { |date| date == '' }
    @errors << "You can't select the same date twice" unless uniq_dates.uniq.count == uniq_dates.count
    if preferred_dates.count > proposal.proposal_type.max_no_of_preferred_dates
      @errors << "You can choose maximum #{proposal.proposal_type.max_no_of_preferred_dates} preferred dates"
    end
    if preferred_dates.count < proposal.proposal_type.min_no_of_preferred_dates
      @errors << "You have to choose atleast #{proposal.proposal_type.min_no_of_preferred_dates} preferred dates"
    end
    if impossible_dates.count > proposal.proposal_type.max_no_of_impossible_dates
      @errors << "You can choose maximum #{proposal.proposal_type.max_no_of_impossible_dates} impossible dates"
    end
    if impossible_dates.count < proposal.proposal_type.min_no_of_impossible_dates
      @errors << "You have to choose atleast #{proposal.proposal_type.min_no_of_impossible_dates} impossible dates"
    end
  end

  def error_message(validation)
    validation.error_message.prepend("Step 2 ##{validation.proposal_field.position} ")
  end

  private

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
