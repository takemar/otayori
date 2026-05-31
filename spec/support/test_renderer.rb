# frozen_string_literal: true

module TestRenderer
  HAML_OPTIONS = { attr_quote: '"' }.freeze
  MARKDOWN_OPTIONS = {
    tables: true,
    fenced_code_blocks: true,
    disable_indented_code_blocks: true,
    link_attributes: { target: '_blank' },
  }.freeze

  module_function

  def haml(text, options = {}, _locals = {})
    scope = options[:scope]
    Tilt['haml'].new(**HAML_OPTIONS) { text }.render(scope)
  end

  def markdown(text, _options = {})
    Tilt['md'].new(**MARKDOWN_OPTIONS) { text }.render
  end

  def erb(text, options = {}, _locals = {})
    scope = options[:scope]
    ERB.new(text).result(scope.instance_eval { binding })
  end
end
