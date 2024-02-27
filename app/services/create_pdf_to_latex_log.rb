# frozen_string_literal: true

class CreatePdfToLatexLog
  include Callable

  def initialize(latex_source, error: nil)
    @error = error
    @latex_source = latex_source
  end

  def call
    LatexToPdfLog.create(log: capture_log, file_name: latex_source)
  end

  private

  def capture_log
    return '' unless error.respond_to?(:log)

    error.log.lines.last(20).join("\n")
  end

  attr_reader :error, :latex_source
end
