# frozen_string_literal: true

module BirsLiquid
  module Renderer
    def liquid(source, context: {})
      ::Liquid::Template.parse(source).render!(context.deep_stringify_keys)
    rescue ::Liquid::Error
      source.to_s
    end
  end
end
