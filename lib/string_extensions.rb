# frozen_string_literal: true

module StringExtensions
  refine String do
    def times(n)
      n.times.map { self }.join
    end
  end
end
