# Uncomment the next line to define a global platform for your project
#plugin 'cocoapods-binary'

source 'https://github.com/CocoaPods/Specs.git'

 platform :ios, '11.0'
install! 'cocoapods',
:deterministic_uuids => false,
:generate_multiple_pod_projects => true

target 'LaunchTimeImproveDemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  # Pods for LaunchTimeImproveDemo
  pod 'A',:path => './LocalPods/A'
  
  pod 'ApplicationModule', :path => './LocalPods/ApplicationModule'
  pod 'LaunchTimeMeasurer', :path => './LocalPods/LaunchTimeMeasurer'
  pod 'LaunchTimeImprover', :path => './LocalPods/LaunchTimeImprover'
  pod 'LaunchManager', :path => './LocalPods/LaunchManager'

#  pod 'AppOrderFiles'
  pod 'QCloudCOSXML'
  pod 'FDFullscreenPopGesture', :path => './LocalPods/FDFullscreenPopGesture'
  
  pod 'SnapKit'
end


def binary_reorder(target)
#    target.build_configurations.each do |config|
#      config.build_settings['OTHER_CFLAGS'] = '-fsanitize-coverage=func,trace-pc-guard'
#      config.build_settings['OTHER_SWIFT_FLAGS'] = '-sanitize-coverage=func -sanitize=undefined'
#    end
end


post_install do |installer|
  installer.generated_projects.each do |target|
#    if target.project_name.to_s == 'QCloudCOSXML' then
#      target.build_configurations.each do |config|
#        config.build_settings['HEADER_SEARCH_PATHS'] = " $(inherited)"\
#         " ${PODS_CONFIGURATION_BUILD_DIR}/QCloudCore/QCloudCore.framework/Headers"\
#      end
#    end

    target.build_configurations.each do |config|      
      config.build_settings['OTHER_CFLAGS'] = '-Wno-incomplete-umbrella'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      config.build_settings['ARCHS'] = "$(ARCHS_STANDARD)"
      config.build_settings["EXCLUDED_ARCHS"] = "armv7 armv7s"
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64 i386"
    end
    target.targets.each do |sub_target|
      sub_target.build_configurations.each do |sub_config|
        sub_config.build_settings['OTHER_CFLAGS'] = '-Wno-incomplete-umbrella'
        sub_config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
        sub_config.build_settings['ARCHS'] = "$(ARCHS_STANDARD)"
        sub_config.build_settings["EXCLUDED_ARCHS"] = "armv7 armv7s"
        sub_config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64 i386"
      end
      binary_reorder(sub_target)
    end
    binary_reorder(target)
  end
end
