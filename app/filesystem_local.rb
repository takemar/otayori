# frozen_string_literal: true

require 'fileutils'
require 'pathname'

module TakemaroBlog; module Filesystem; end; end

class TakemaroBlog::Filesystem::Local
  def initialize(root, renderer)
    @root = Pathname.new(root)
    @renderer = renderer
  end

  def close; end

  def mkdir(dir)
    FileUtils.mkdir_p(@root + dir)
  end

  def mkfile(arg, app)
    path = local_file(arg.path)
    FileUtils.mkdir_p(path.dirname)
    path.write(arg.render(app))
  end

  def glob(path, pattern)
    directory = pattern.end_with?('/')
    pattern = pattern.chop if directory
    base = @root + path
    results = Dir.glob(pattern, base: base.to_s)
    if directory
      results.select! { |name| (base + name).directory? }
    end
    results
  end

  private

    def local_file(path)
      @root + "#{ path }#{
        'index' if path.end_with?('/') || path.empty?
      }#{
        '.html' unless path.end_with?('.html')
      }"
    end

end
