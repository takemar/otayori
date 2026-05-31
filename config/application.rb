# frozen_string_literal: true

require 'active_record'
require 'active_support/core_ext/time'

ActiveRecord::Base.time_zone_aware_attributes = true
ActiveRecord.default_timezone = :utc
Time.zone = 'Asia/Tokyo'

env_file = ENV['APP_ENV'] == 'test' ? 'environment.example' : 'environment'
require_relative env_file
