#!/usr/bin/env ruby
require 'xcodeproj'

PROJECT_PATH = File.expand_path("ios/Runner.xcodeproj")
WATCH_APP_DIR = "WatchApp"
WATCH_EXT_DIR = "WatchExtension"

project = Xcodeproj::Project.open(PROJECT_PATH)
main_group = project.main_group

# =====================
# Create Watch Extension
# =====================
ext_target = project.new_target(
  :watch2_extension,
  "WatchExtension",
  :watchos,
  nil,
  nil,
  :swift
)

# Set correct bundle ID
ext_target.build_configurations.each do |config|
  config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = "com.example.passwordGeneratorApp.watchkitapp.extension"
  config.build_settings["INFOPLIST_FILE"] = "#{WATCH_EXT_DIR}/Info.plist"
end

# Add Swift files to extension
ext_group = main_group.find_subpath(WATCH_EXT_DIR, true)
ext_group.set_source_tree("SOURCE_ROOT")

Dir.glob("#{WATCH_EXT_DIR}/*.swift").each do |file|
  ref = ext_group.new_reference(file)
  ext_target.source_build_phase.add_file_reference(ref)
end

# Info.plist
plist_ref = ext_group.new_reference("#{WATCH_EXT_DIR}/Info.plist")
ext_target.resources_build_phase.add_file_reference(plist_ref)

# =====================
# Create Watch App
# =====================
watch_target = project.new_target(
  :watch2_app,
  "WatchApp",
  :watchos,
  nil,
  nil,
  :swift
)

watch_target.build_configurations.each do |config|
  config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = "com.example.passwordGeneratorApp.watchkitapp"
  config.build_settings["INFOPLIST_FILE"] = "#{WATCH_APP_DIR}/Info.plist"
end

# Add Watch App files
watch_group = main_group.find_subpath(WATCH_APP_DIR, true)
watch_group.set_source_tree("SOURCE_ROOT")

watch_plist = watch_group.new_reference("#{WATCH_APP_DIR}/Info.plist")
watch_target.resources_build_phase.add_file_reference(watch_plist)

# =====================
# Embed Extension in Watch App
# =====================
ext_ref = ext_target.product_reference
embed_phase = watch_target.new_copy_files_build_phase("Embed App Extensions")
embed_phase.dst_subfolder_spec = "13"
embed_phase.add_file_reference(ext_ref) if ext_ref

# =====================
# Embed Watch App in Runner
# =====================
runner = project.targets.find { |t| t.name == "Runner" }
if runner
  runner_embed = runner.new_copy_files_build_phase("Embed Watch Content")
  runner_embed.dst_subfolder_spec = "13"

  watch_ref = watch_target.product_reference
  runner_embed.add_file_reference(watch_ref) if watch_ref

  # Add target dependencies
  dep1 = project.new(Xcodeproj::Project::Object::PBXTargetDependency)
  dep1.name = "WatchExtension"
  dep1.target = ext_target
  runner.dependencies << dep1

  dep2 = project.new(Xcodeproj::Project::Object::PBXTargetDependency)
  dep2.name = "WatchApp"
  dep2.target = watch_target
  runner.dependencies << dep2
end

project.save
puts "✅ Watch targets added successfully!"
puts "   - WatchApp (com.example.passwordGeneratorApp.watchkitapp)"
puts "   - WatchExtension (com.example.passwordGeneratorApp.watchkitapp.extension)"
puts ""
puts "⚠️ Next steps (required in Xcode):"
puts "   1. Open ios/Runner.xcworkspace"
puts "   2. Select both Watch targets and set a valid Team in Signing & Capabilities"
puts "   3. Add an App Group capability to all 3 targets (Runner, WatchApp, WatchExtension)"
puts "   4. Build with a Watch scheme (or use 'Any watchOS Device' as destination)"
