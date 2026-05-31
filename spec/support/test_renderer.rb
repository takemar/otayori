# frozen_string_literal: true

require 'ostruct'

module TestRenderer
  HAML_OPTIONS = { attr_quote: '"' }.freeze
  MARKDOWN_OPTIONS = {
    tables: true,
    fenced_code_blocks: true,
    disable_indented_code_blocks: true,
    link_attributes: { target: '_blank' },
  }.freeze

  module_function

  def settings
    OpenStruct.new(root: File.expand_path('../../app', __dir__))
  end

  def haml(template, options = {}, locals = {}, &block)
    scope = options[:scope]
    layout_false = options[:layout] == false
    all_locals = options.fetch(:locals, {}).merge(locals)

    if template.is_a?(Symbol)
      views_dir = options[:views] || File.join(settings.root, 'views')
      path = File.join(views_dir, "#{template}.haml")
      inner = Tilt.new(path, **HAML_OPTIONS).render(scope, all_locals, &block)

      unless layout_false
        layout_path = File.join(views_dir, 'layout.haml')
        inner = Tilt.new(layout_path, **HAML_OPTIONS).render(scope) { inner } if File.exist?(layout_path)
      end
      inner
    else
      Tilt['haml'].new(**HAML_OPTIONS) { template }.render(scope, all_locals)
    end
  end

  def markdown(text, _options = {})
    Tilt['md'].new(**MARKDOWN_OPTIONS) { text }.render
  end

  def erb(text, options = {}, _locals = {})
    scope = options[:scope]
    ERB.new(text).result(scope.instance_eval { binding })
  end
end
