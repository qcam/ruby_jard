# frozen_string_literal: true

module RubyJard
  class Row
    extend Forwardable

    attr_accessor :row_template, :columns

    def_delegators :@row_template, :line_limit

    def initialize(row_template:, columns: [])
      @row_template = row_template
      @columns = columns
    end
  end
end
