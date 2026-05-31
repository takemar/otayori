# frozen_string_literal: true

require 'active_record'
require 'active_support/core_ext/time'

ActiveRecord::Base.time_zone_aware_attributes = true
ActiveRecord.default_timezone = :utc
Time.zone = 'Asia/Tokyo'

env_file = case ENV['APP_ENV']
           when 'test'    then 'environment.example'
           when 'staging' then 'environment.staging'
           else                'environment'
           end
require_relative env_file
