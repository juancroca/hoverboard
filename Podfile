# 10.13+ is required for current Xcode: older targets pull in libarclite (removed from the SDK).
platform :osx, '10.13'

target 'Hoverboard' do
    # Comment the next line if you're not using Swift and don't want to use
    # dynamic frameworks
    use_frameworks!

    # Pods for Hoverboard
    # ElsloooKit was hosted at elsl.ooo (domain no longer resolves); About uses NSApp.orderFrontStandardAboutPanel instead.
    pod 'HockeySDK-Mac'
    pod 'LetsMove'
    pod 'Sparkle'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.13'
      # Sparkle 1.x / HockeySDK pods are x86_64-only; exclude arm64 so the link
      # step matches Apple Silicon builds (Rosetta at runtime).
      config.build_settings['EXCLUDED_ARCHS[sdk=macosx*]'] = 'arm64'
    end
  end
end
