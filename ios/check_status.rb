#!/usr/bin/env ruby

require 'spaceship'

# Set up App Store Connect API
Spaceship::ConnectAPI.token = Spaceship::ConnectAPI::Token.from(
  filepath: "../assets/AuthKey_5GQ446J4X4.p8",
  key_id: "5GQ446J4X4",
  issuer_id: "69a6de92-65ac-47e3-e053-5b8c7c11a4d1"
)

begin
  # Get the app
  app = Spaceship::ConnectAPI::App.find("com.example.multitimerTrackfield")
  
  if app
    puts "📱 App found: #{app.name}"
    
    # Get app store versions
    app_store_versions = app.get_app_store_versions
    
    puts "\n📋 App Store Versions:"
    app_store_versions.each do |version|
      puts "  Version: #{version.version_string}"
      puts "  State: #{version.app_store_state}"
      puts "  Created: #{version.created_date}"
      
      if version.app_store_state == "WAITING_FOR_REVIEW" || 
         version.app_store_state == "IN_REVIEW" ||
         version.app_store_state == "PENDING_DEVELOPER_RELEASE"
        puts "  ⚠️  This version is blocking new submissions!"
      end
      puts "  ---"
    end
    
    # Get builds for latest version
    latest_version = app_store_versions.first
    if latest_version
      builds = latest_version.get_builds
      puts "\n🔨 Builds for version #{latest_version.version_string}:"
      builds.each do |build|
        puts "  Build: #{build.version}"
        puts "  State: #{build.processing_state}"
        puts "  ---"
      end
    end
    
  else
    puts "❌ App not found with identifier: com.example.multitimerTrackfield"
  end
  
rescue => e
  puts "❌ Error: #{e.message}"
  puts "   This might be a permissions issue or the app identifier might be incorrect."
end
