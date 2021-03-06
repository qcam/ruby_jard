# frozen_string_literal: true

module RubyJard
  module Decorators
    ##
    # Decorate a line of code fetched from the source file.
    # The line is tokenized, and feed into JardEncoder to append color (with
    # Span).
    class LocDecorator
      attr_reader :spans, :tokens

      def initialize(loc)
        @loc = loc
        @encoder = JardLocEncoder.new

        decorate
      end

      def decorate
        @tokens = CodeRay.scan(@loc, :ruby)
        @spans = @encoder.encode_tokens(tokens)
      end

      # A shameless copy from https://github.com/rubychan/coderay/blob/master/lib/coderay/encoders/terminal.rb
      class JardLocEncoder < CodeRay::Encoders::Encoder
        DEFAULT_COLOR = [:white].freeze
        TOKEN_COLORS = {
          debug: [:white, :on_blue],
          annotation: [:blue],
          attribute_name: [:blue],
          attribute_value: [:blue],
          binary: {
            self: [:blue],
            char: [:blue],
            delimiter: [:blue]
          },
          char: {
            self: [:blue],
            delimiter: [:blue]
          },
          class: [:underline, :green],
          class_variable: [:green],
          color: [:green],
          comment: {
            self: [:white],
            char: [:white],
            delimiter: [:white]
          },
          constant: [:green],
          decorator: [:blue],
          definition: [:blue],
          directive: [:blue],
          docstring: [:blue],
          doctype: [:blue],
          done: [:blue],
          entity: [:blue],
          error: [:white, :on_red],
          exception: [:blue],
          float: [:blue],
          function: [:green],
          method: [:green],
          global_variable: [:green],
          hex: [:blue],
          id: [:blue],
          include: [:blue],
          integer: [:blue],
          imaginary: [:blue],
          important: [:blue],
          key: {
            self: [:blue],
            char: [:blue],
            delimiter: [:blue]
          },
          label: [:blue],
          local_variable: [:blue],
          namespace: [:blue],
          octal: [:blue],
          predefined: [:blue],
          predefined_constant: [:blue],
          predefined_type: [:green],
          preprocessor: [:blue],
          pseudo_class: [:blue],
          regexp: {
            self: [:blue],
            delimiter: [:blue],
            modifier: [:blue],
            char: [:blue]
          },
          reserved: [:blue],
          keyword: [:blue],
          shell: {
            self: [:blue],
            char: [:blue],
            delimiter: [:blue],
            escape: [:blue]
          },
          string: {
            self: [:blue],
            modifier: [:blue],
            char: [:blue],
            delimiter: [:blue],
            escape: [:blue]
          },
          symbol: {
            self: [:blue],
            delimiter: [:blue]
          },
          tag: [:green],
          type: [:blue],
          value: [:blue],
          variable: [:blue],
          insert: {
            self: [:on_green],
            insert: [:green, :on_green],
            eyecatcher: [:italic]
          },
          delete: {
            self: [:on_red],
            delete: [:blue, :on_red],
            eyecatcher: [:italic]
          },
          change: {
            self: [:on_blue],
            change: [:white, :on_blue]
          },
          head: {
            self: [:on_red],
            filename: [:white, :on_red]
          },
          instance_variable: [:blue]
        }.freeze

        protected

        def setup(options)
          super
          @opened = []
          @color_scopes = [TOKEN_COLORS]
          @out = []
        end

        public

        def text_token(text, kind)
          color = @color_scopes.last[kind]
          text.gsub!("\n", '')
          styles =
            if !color
              DEFAULT_COLOR
            elsif color.is_a? Hash
              color[:self]
            else
              color
            end
          @out << Span.new(
            span_template: nil,
            content: text,
            content_length: text.length,
            styles: styles
          )
        end

        def begin_group(kind)
          @opened << kind
          open_token(kind)
        end
        alias begin_line begin_group

        def end_group(_kind)
          return unless @opened.pop

          @color_scopes.pop
        end

        def end_line(kind)
          end_group(kind)
        end

        private

        def open_token(kind)
          color = @color_scopes.last[kind]
          @color_scopes <<
            if color
              if color.is_a?(Hash)
                color
              else
                @color_scopes.last
              end
            else
              @color_scopes.last
            end
        end
      end
    end
  end
end
