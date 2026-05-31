# frozen_string_literal: true

require 'spec_helper'
require 'support/test_renderer'

# Minimal stubs for webdir objects used by archive view classes
class FakeWebdir
  def months_html = []
  def tags_by_year = Hash.new([])
end

class FakeWebdirList
  def initialize(tag: nil) = @tag = tag
  attr_reader :tag
  def prev_of(_) = nil
  def succ_of(_) = nil
end

class FakeWebdirItem
  def initialize(year:, month: nil)
    @year = year
    @month = month
  end
  attr_reader :year, :month
end

RSpec.describe 'render' do
  let(:tag) { Tag.create!(name: 'Test Tag', slug: 'test-tag', order: 1) }

  def make_post(**attrs)
    Post.create!({
      title: 'Post Title', slug: 'test-post', description: 'desc',
      format: 'html', text: '<p>body</p>', tags: [tag],
    }.merge(attrs))
  end

  # ---

  describe 'PostView#render' do
    subject(:rendered) { make_post.render(TestRenderer) }

    it 'produces a full HTML page' do
      expect(rendered).to include('<!DOCTYPE')
      expect(rendered).to include('<html')
    end

    it 'includes title in h1' do
      expect(rendered).to include('<h1>Post Title</h1>')
    end

    it 'includes rendered body' do
      expect(rendered).to include('<p>body</p>')
    end

    it 'includes stylesheet links' do
      expect(rendered).to include('<link')
    end

    it 'does not include footnote section when no footnotes' do
      expect(rendered).not_to include('class="footnotes"')
    end

    it 'includes prev post link when prev exists' do
      older = make_post(slug: 'older', title: 'Older Post')
      older.update_column(:created_at, 1.year.ago)
      current = make_post(slug: 'current')
      expect(current.render(TestRenderer)).to include('Older Post')
    end

    it 'includes succ post link when succ exists' do
      current = make_post(slug: 'current')
      current.update_column(:created_at, 1.year.ago)
      make_post(slug: 'newer', title: 'Newer Post')
      expect(current.reload.render(TestRenderer)).to include('Newer Post')
    end

    it 'includes tag link' do
      expect(rendered).to include('test-tag')
    end
  end

  # ---

  describe 'Root#render' do
    before { make_post }

    subject(:rendered) { TakemaroBlog::View::Root.new.render(TestRenderer) }

    it 'produces a full HTML page (own DOCTYPE, no layout wrapper)' do
      expect(rendered).to include('<!DOCTYPE')
      expect(rendered).to include('<html')
    end

    it 'includes blog heading' do
      expect(rendered).to include('My Example Blog')
    end

    it 'includes post in listing' do
      expect(rendered).to include('Post Title')
    end
  end

  # ---

  describe 'Archive#render' do
    MonthLike = Struct.new(:year, :month) unless defined?(MonthLike)

    before do
      p = make_post
      p.update_column(:created_at, Time.zone.local(2024, 1, 15))
    end

    subject(:rendered) do
      TakemaroBlog::View::Archive.new([2024], [MonthLike.new(2024, 1)]).render(TestRenderer)
    end

    it 'produces HTML' do
      expect(rendered).to include('<html')
    end

    it 'includes archive heading' do
      expect(rendered).to include('アーカイブ')
    end

    it 'includes year link' do
      expect(rendered).to include('2024')
    end
  end

  # ---

  describe 'Tags#render' do
    before do
      p = make_post
      p.update_column(:created_at, Time.zone.local(2024, 1, 15))
    end

    subject(:rendered) do
      TakemaroBlog::View::Tags.new({ 'test-tag' => [2024] }).render(TestRenderer)
    end

    it 'produces HTML' do
      expect(rendered).to include('<html')
    end

    it 'includes tags heading' do
      expect(rendered).to include('タグ')
    end

    it 'includes tag name' do
      expect(rendered).to include('Test Tag')
    end
  end

  # ---

  describe 'TagView#render' do
    before do
      p = make_post
      p.update_column(:created_at, Time.zone.local(2024, 1, 15))
    end

    subject(:rendered) do
      TakemaroBlog::View::TagView.new(tag, [2024]).render(TestRenderer)
    end

    it 'produces HTML' do
      expect(rendered).to include('<html')
    end

    it 'includes tag name' do
      expect(rendered).to include('Test Tag')
    end

    it 'includes post in listing' do
      expect(rendered).to include('Post Title')
    end
  end

  # ---

  describe 'Month#render' do
    before do
      p = make_post
      p.update_column(:created_at, Time.zone.local(2024, 1, 15))
    end

    subject(:rendered) do
      TakemaroBlog::View::Month.new(
        FakeWebdir.new,
        FakeWebdirList.new,
        FakeWebdirItem.new(year: 2024, month: 1)
      ).render(TestRenderer)
    end

    it 'produces HTML' do
      expect(rendered).to include('<html')
    end

    it 'includes year/month heading' do
      expect(rendered).to include('2024')
      expect(rendered).to include('1月')
    end

    it 'includes post in listing' do
      expect(rendered).to include('Post Title')
    end
  end

  # ---

  describe 'Year#render' do
    before do
      p = make_post
      p.update_column(:created_at, Time.zone.local(2024, 6, 15))
    end

    subject(:rendered) do
      TakemaroBlog::View::Year.new(
        FakeWebdir.new,
        FakeWebdirList.new,
        FakeWebdirItem.new(year: 2024)
      ).render(TestRenderer)
    end

    it 'produces HTML' do
      expect(rendered).to include('<html')
    end

    it 'includes year heading' do
      expect(rendered).to include('2024')
    end
  end

  # ---

  describe 'TagArchive#render' do
    before do
      p = make_post
      p.update_column(:created_at, Time.zone.local(2024, 6, 15))
    end

    subject(:rendered) do
      TakemaroBlog::View::TagArchive.new(
        FakeWebdir.new,
        FakeWebdirList.new(tag: tag),
        FakeWebdirItem.new(year: 2024)
      ).render(TestRenderer)
    end

    it 'produces HTML' do
      expect(rendered).to include('<html')
    end

    it 'includes tag name' do
      expect(rendered).to include('Test Tag')
    end

    it 'includes year' do
      expect(rendered).to include('2024')
    end

    it 'includes post in listing' do
      expect(rendered).to include('Post Title')
    end
  end
end
