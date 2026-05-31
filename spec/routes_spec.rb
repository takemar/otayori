# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TakemaroBlog::Application do
  def app = TakemaroBlog::Application

  let(:tag_params) { { 'title' => 'Test Post', 'slug' => 'test-post', 'description' => 'desc', 'format' => 'markdown', 'text' => '# Hello', 'tags' => ['test-tag'] } }

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
      post '/blog/new', tag_params
      expect(last_response.status).to eq(200)
    end
  end

  describe 'POST /blog/create' do
    it 'redirects after creating a post' do
      post '/blog/create', tag_params
      expect(last_response.status).to eq(302)
    end
  end
end
