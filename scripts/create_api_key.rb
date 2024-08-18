# frozen_string_literal: true

# Check if the script is run with Rails runner
unless defined?(Rails)
  puts 'This script should be run using `rails runner`.'
  exit 1
end

# Require the necessary files
require_relative '../config/environment'

# Create a new API key
api_key = ApiKey.create!(status: :active)

# Output the generated API key
puts 'API Key created successfully!'
puts "Key: #{api_key.key}"
puts "Status: #{api_key.status}"
puts "Expires at: #{api_key.expired_at}"
