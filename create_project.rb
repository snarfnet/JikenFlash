require 'xcodeproj'

PROJECT_NAME = 'JikenFlash'
BUNDLE_ID = 'com.tokyonasu.JikenFlash'
TEAM_ID = '83VGKGSQUH'

project_path = File.expand_path("#{PROJECT_NAME}.xcodeproj", __dir__)
project = Xcodeproj::Project.new(project_path)
target = project.new_target(:application, PROJECT_NAME, :ios, '17.0')

target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = BUNDLE_ID
  config.build_settings['DEVELOPMENT_TEAM'] = TEAM_ID
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['INFOPLIST_FILE'] = 'JikenFlash/Info.plist'
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
  config.build_settings['ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME'] = 'AccentColor'
end

main_group = project.main_group
app_group = main_group.new_group(PROJECT_NAME, PROJECT_NAME)

def add_sources(group, target, names)
  names.each do |name|
    ref = group.new_file(name)
    target.add_file_references([ref])
  end
end

add_sources(app_group, target, [
  'JikenFlashApp.swift',
  'AppDelegate.swift',
  'ContentView.swift',
  'Models.swift',
  'Services.swift',
  'NewsViews.swift',
  'SettingsView.swift',
  'BannerAdView.swift',
  'JikenTheme.swift',
])

assets_ref = app_group.new_file('Assets.xcassets')
target.add_resources([assets_ref])
privacy_ref = app_group.new_file('PrivacyInfo.xcprivacy')
target.add_resources([privacy_ref])
app_group.new_file('Info.plist')

project.save
puts "Created #{project_path}"
