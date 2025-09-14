#!/usr/bin/env ruby

puts "🚀 TestFlight Upload - Direct Action Method"

# Create a temporary API key file in the ios directory
key_content = File.read('../assets/AuthKey_LX4RW29VFH.p8')
temp_key_file = 'AuthKey_LX4RW29VFH.p8'
File.write(temp_key_file, key_content)

puts "✅ Temporary API key file created: #{temp_key_file}"

# Use bundle exec fastlane run directly
cmd = [
  'bundle', 'exec', 'fastlane', 'run', 'upload_to_testflight',
  "ipa:./build/Runner.ipa",
  "api_key:{key_id:#{ENV['APP_STORE_CONNECT_API_KEY_ID']},issuer_id:#{ENV['APP_STORE_CONNECT_ISSUER_ID']},key_filepath:#{File.expand_path(temp_key_file)}}",
  "skip_waiting_for_build_processing:false",
  "changelog:UI/UX Improvements: Fixed logo color matching, improved fonts and layout",
  "distribute_external:false",
  "notify_external_testers:false"
]

puts "Running: #{cmd.join(' ')}"
result = system(*cmd)

# Clean up
File.delete(temp_key_file) if File.exist?(temp_key_file)
puts "🧹 Cleaned up temporary files"

if result
  puts "✅ Upload completed successfully!"
else
  puts "❌ Upload failed"
  exit 1
end
