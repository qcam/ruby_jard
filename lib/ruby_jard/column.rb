# frozen_string_literal: true

module RubyJard
  class Column
    extend Forwardable

    attr_accessor :column_template, :spans, :content_length, :width

    def_delegators :@column_template, :margin_left, :margin_right

    def initialize(column_template:)
      @column_template = column_template
      @spans = []
      @width = 0
      @content_length = 0
    end
  end
end
