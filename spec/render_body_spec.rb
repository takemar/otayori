# frozen_string_literal: true

require 'spec_helper'
require 'support/test_renderer'

RSpec.describe 'PostView#render_body' do
  def make_post(format:, text:)
    Post.create!(format: format, text: text, title: 'T', slug: 's', description: 'd')
  end

  describe 'html format' do
    it 'passes through HTML as-is' do
      expect(make_post(format: 'html', text: '<b>bold</b>').render_body(TestRenderer)).to include('<b>bold</b>')
    end

    it 'strips leading/trailing whitespace from each line' do
      expect(make_post(format: 'html', text: '  <b>x</b>  ').render_body(TestRenderer)).to include('<b>x</b>')
    end

    it 'removes blank lines' do
      result = make_post(format: 'html', text: "<b>a</b>\n\n<b>b</b>").render_body(TestRenderer)
      expect(result).to include('<b>a</b>')
      expect(result).to include('<b>b</b>')
      expect(result).not_to include("\n\n")
    end

    it 'returns empty string for empty text' do
      expect(make_post(format: 'html', text: '').render_body(TestRenderer)).to eq('')
    end

    it 'returns empty string for whitespace-only text' do
      expect(make_post(format: 'html', text: "\n\n\n").render_body(TestRenderer)).to eq('')
    end

    it 'does not evaluate ERB' do
      expect(make_post(format: 'html', text: '<%= 1 + 1 %>').render_body(TestRenderer)).to include('<%= 1 + 1 %>')
    end
  end

  describe 'markdown format' do
    it 'renders headings' do
      expect(make_post(format: 'markdown', text: '# Hello').render_body(TestRenderer)).to include('<h1>Hello</h1>')
    end

    it 'renders fenced code blocks' do
      expect(make_post(format: 'markdown', text: "```\ncode\n```").render_body(TestRenderer)).to include('<code>')
    end

    it 'adds target="_blank" to links' do
      result = make_post(format: 'markdown', text: '[text](http://example.com)').render_body(TestRenderer)
      expect(result).to include('target="_blank"')
    end

    it 'renders tables' do
      src = "| a | b |\n|---|---|\n| 1 | 2 |"
      expect(make_post(format: 'markdown', text: src).render_body(TestRenderer)).to include('<table>')
    end

    it 'HTML-escapes ERB tags (does not evaluate)' do
      expect(make_post(format: 'markdown', text: '<%= 1 + 1 %>').render_body(TestRenderer)).to include('&lt;%=')
    end
  end

  describe 'haml format' do
    it 'renders basic haml' do
      expect(make_post(format: 'haml', text: '%p hello').render_body(TestRenderer)).to include('<p>hello</p>')
    end

    it 'evaluates inline Ruby' do
      expect(make_post(format: 'haml', text: '%p= 1 + 1').render_body(TestRenderer)).to include('<p>2</p>')
    end

    it 'renders nested elements' do
      result = make_post(format: 'haml', text: "%div\n  %p hello").render_body(TestRenderer)
      expect(result).to include('<div>')
      expect(result).to include('<p>hello</p>')
    end

    it 'scope is PostView (url() is available)' do
      result = make_post(format: 'haml', text: "= url('test/path')").render_body(TestRenderer)
      expect(result).to include('/test/path')
    end
  end

  describe 'line normalization (all formats)' do
    it 'collapses blank lines between tags' do
      result = make_post(format: 'html', text: "<p>a</p>\n\n<p>b</p>").render_body(TestRenderer)
      expect(result).to eq("<p>a</p>\n<p>b</p>")
    end

    it 'strips the whole line but not content inside tags' do
      result = make_post(format: 'html', text: '  <p>  a  </p>  ').render_body(TestRenderer)
      expect(result).to eq('<p>  a  </p>')
    end
  end
end
