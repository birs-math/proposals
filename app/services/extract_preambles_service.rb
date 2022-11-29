class ExtractPreamblesService
  attr_reader :proposals
  def initialize(proposals)
    @proposals = proposals
    @proposals_object = []
    @preambles = []
    # skip any whose preambles are blank, collect an array of codes & preambles
    @proposals.split(',').each do |id|
      @proposal = Proposal.find_by(id: id)
      @proposals_object << @proposal
      next if @proposal.macros.blank?

      @preambles << { code: @proposal.code, preamble: @proposal.preamble }
    end
  end

  # expects an array @preambles of {code, preamble} pairs
  def proposal_preambles
    declare_definitions
    @newlines = ''
    @preambles.each do |proposal|
      @proposal = proposal
      if proposal[:preamble].start_with?("%")
        @newlines << "#{proposal[:preamble]}\n\n"
      else
        duplicate_preambles
      end
    end
    @newlines
  end

  def declare_definitions
    @all_definitions = {
      'usepackage' => [],
      'newcommand_with_brackets' => [],
      'newcommand' => [],
      'def' => [],
      'DeclareMathOperator' => [],
      'providecommand' => [],
      'providecommand_with_brackets' => [],
      'RequirePackage' => []
    }
  end

  def duplicate_preambles
    @preamble = @proposal[:preamble].delete(' ')
    definitions = extract_definitions(@preamble)
    remove_duplicates(definitions, @proposal[:preamble])
  end

  def extract_definitions(preamble)
    preamble_usepackage(preamble)
    {
      'usepackage' => @macro_name,
      'newcommand_with_brackets' => preamble.scan(/\\newcommand{\\(\w+)}/).flatten.join,
      'newcommand' => preamble.scan(/\\newcommand\\(\w+)/).flatten.join,
      'def' => preamble.scan(/\\def\\(\w+){/).flatten.join,
      'DeclareMathOperator' => preamble.scan(/\\DeclareMathOperator{\\(\w+)}/).flatten.join,
      'providecommand_with_brackets' => preamble.scan(/\\providecommand{\\(\w+)}/).flatten.join,
      'providecommand' => preamble.scan(/\\providecommand\\(\w+)/).flatten.join,
      'RequirePackage' => preamble.scan(/\\RequirePackage\[(\w+)/).flatten.join
    }
  end

  def preamble_usepackage(preamble)
    return unless preamble.include?("usepackage")

    @macro_name = preamble.split('{')
    @macro_name = if @macro_name.present? && @macro_name[1].present?
                    @macro_name[1].split('}')[0]
                  else
                    @macro_name&.join
                  end
  end

  def remove_duplicates(definitions, preamble)
    definitions.each do |command, definition|
      next unless [command, definition].all? && definition.present? && preamble.include?(definition)

      @command = command
      @definition = definition

      if @all_definitions[@command].include?(@definition) || check_condition
        @newlines << "\n\\begin{comment}\n\n #{preamble}\n\\end{comment}\n\n"
      else
        @all_definitions[command] << definition
        @newlines << "#{preamble}\n\n"
      end
    end
    @newlines
  end

  def check_condition
    (@command == 'newcommand_with_brackets' && @all_definitions['newcommand'].include?(@definition)) or
      (@command == 'newcommand' &&
        @all_definitions['newcommand_with_brackets'].include?(@definition)) or check_condition_providecommand
  end

  def check_condition_providecommand
    (@command == 'providecommand_with_brackets' && @all_definitions['providecommand'].include?(@definition)) or
      (@command == 'providecommand' && @all_definitions['providecommand_with_brackets'].include?(@definition))
  end
end