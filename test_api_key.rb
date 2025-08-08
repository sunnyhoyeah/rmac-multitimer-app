#!/usr/bin/env ruby

require 'base64'
require 'fileutils'

# Test script to validate API key configuration
# This simulates what happens in the GitHub Actions workflow

puts "🔍 Testing API key configuration..."

# Test the key files we have
key_files = Dir.glob("assets/AuthKey_*.p8")
puts "Found key files: #{key_files}"

key_files.each do |key_file|
  puts "\n📄 Testing #{key_file}:"
  
  # Extract key ID from filename
  key_id = File.basename(key_file, '.p8').split('_').last
  puts "  Key ID: #{key_id}"
  
  # Read the key content
  key_content = File.read(key_file)
  puts "  Key format: #{key_content.lines.first.strip}"
  puts "  Key lines: #{key_content.lines.count}"
  
  # Create base64 version
  base64_key = Base64.strict_encode64(key_content)
  puts "  Base64 length: #{base64_key.length}"
  
  # Test decoding
  begin
    decoded_key = Base64.decode64(base64_key)
    if decoded_key == key_content
      puts "  ✅ Base64 encode/decode successful"
    else
      puts "  ❌ Base64 encode/decode failed - content mismatch"
    end
  rescue => e
    puts "  ❌ Base64 decode error: #{e.message}"
  end
  
  # Test creating a temp file and validating format
  begin
    temp_file = "temp_#{key_id}.p8"
    File.write(temp_file, Base64.decode64(base64_key))
    
    temp_content = File.read(temp_file)
    if temp_content.include?("BEGIN PRIVATE KEY") || temp_content.include?("BEGIN EC PRIVATE KEY")
      puts "  ✅ Temp file contains valid private key format"
    else
      puts "  ❌ Temp file does not contain valid private key format"
      puts "  Content preview: #{temp_content[0..50]}..."
    end
    
    File.delete(temp_file) if File.exist?(temp_file)
  rescue => e
    puts "  ❌ Temp file test error: #{e.message}"
  end
  
  puts "  📋 For GitHub Secrets:"
  puts "    APP_STORE_CONNECT_API_KEY_ID: #{key_id}"
  puts "    APP_STORE_CONNECT_API_KEY: #{base64_key[0..50]}..."
end

puts "\n🎯 Recommendations:"
puts "1. Ensure APP_STORE_CONNECT_API_KEY_ID matches one of the key IDs above"
puts "2. Ensure APP_STORE_CONNECT_API_KEY contains the full base64 string"
puts "3. Ensure APP_STORE_CONNECT_ISSUER_ID is set to your App Store Connect issuer ID"
puts "4. Check that there are no extra spaces or line breaks in the GitHub secrets"
