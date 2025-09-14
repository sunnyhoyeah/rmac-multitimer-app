#!/usr/bin/env ruby

puts "🚀 Direct TestFlight Upload using xcrun altool"

# Check if IPA exists
ipa_path = './build/Runner.ipa'
unless File.exist?(ipa_path)
  puts "❌ IPA file not found: #{ipa_path}"
  exit 1
end

puts "✅ Found IPA file: #{ipa_path}"

# Use xcrun altool for upload
key_id = ENV['APP_STORE_CONNECT_API_KEY_ID']
issuer_id = ENV['APP_STORE_CONNECT_ISSUER_ID']  
key_file = File.expand_path('../assets/AuthKey_LX4RW29VFH.p8', __dir__)

puts "📤 Uploading to App Store Connect..."
puts "Key ID: #{key_id}"
puts "Issuer ID: #{issuer_id}"
puts "Key file: #{key_file}"

cmd = [
  'xcrun', 'altool',
  '--upload-app',
  '--type', 'ios',
  '--file', ipa_path,
  '--apiKey', key_id,
  '--apiIssuer', issuer_id
]

puts "Running: #{cmd.join(' ')}"
system(*cmd)
