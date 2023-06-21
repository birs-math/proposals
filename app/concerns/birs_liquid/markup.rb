# frozen_string_literal: true

module BirsLiquid
  module Markup
    include Renderer

    def render(attr, context: {})
      liquid(public_send(attr.to_sym), context: context)
    end
  end
end
