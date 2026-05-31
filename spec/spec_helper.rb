# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

require 'fileutils'
require 'rack/test'
require_relative '../app/boot'

ActiveRecord::Schema.verbose = false
load File.expand_path('../db/schema.rb', __dir__)

Post.source_dir = File.expand_path('../tmp/test_source', __dir__)
FileUtils.mkdir_p Post.source_dir

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.around(:each) do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end

  config.after(:suite) do
    FileUtils.rm_rf File.expand_path('../tmp/webdir_test', __dir__)
    FileUtils.rm_rf File.expand_path('../tmp/test_source', __dir__)
  end
end
