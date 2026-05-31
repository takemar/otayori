# frozen_string_literal: true

require 'spec_helper'
require 'json'

RSpec.describe TakemaroBlog::Application do
  def app = TakemaroBlog::Application

  let(:base_params) { { 'title' => 'Test Post', 'slug' => 'test-post', 'description' => 'desc', 'format' => 'markdown', 'text' => '# Hello', 'tags' => ['test-tag'] } }

  before do
    Tag.create!(name: 'Test Tag', slug: 'test-tag', order: 1)
  end

  describe 'GET /blog/new' do
    it 'returns 200' do
      get '/blog/new'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'POST /blog/new (preview)' do
    it 'returns 200' do
      post '/blog/new', base_params
      expect(last_response.status).to eq(200)
    end
  end

  describe 'POST /blog/create' do
    it 'redirects after creating a post' do
      post '/blog/create', base_params
      expect(last_response.status).to eq(302)
    end
  end

  describe 'format smoke tests (POST /blog/new)' do
    FORMAT_CASES = {
      'html'     => { text: '<b>hello</b>',  expect: '<b>hello</b>' },
      'markdown' => { text: '# Hello',       expect: '<h1>Hello</h1>' },
      'haml'     => { text: '%p hello',      expect: '<p>hello</p>' },
    }.freeze

    def compiled_source(format:, text:)
      post '/blog/new', base_params.merge('format' => format, 'text' => text)
      match = last_response.body.match(/<script[^>]*id="rawdata"[^>]*>(.*?)<\/script>/m)
      raise "rawdata not found (status: #{last_response.status})" unless match
      JSON.parse(match[1])
    end

    FORMAT_CASES.each do |fmt, cfg|
      context "format=#{fmt}" do
        it 'returns 200' do
          post '/blog/new', base_params.merge('format' => fmt, 'text' => cfg[:text])
          expect(last_response.status).to eq(200)
        end

        it 'renders expected output' do
          expect(compiled_source(format: fmt, text: cfg[:text])).to include(cfg[:expect])
        end
      end
    end
  end
end
