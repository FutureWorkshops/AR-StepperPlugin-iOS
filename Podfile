source 'https://cdn.cocoapods.org/'
source 'https://github.com/FutureWorkshops/MWPodspecs.git'

workspace 'Stepper'
platform :ios, '15.0'

inhibit_all_warnings!
use_frameworks!

project 'Stepper/Stepper.xcodeproj'
project 'StepperPlugin/StepperPlugin.xcodeproj'

abstract_target 'MobileWorkflow' do
  pod 'MobileWorkflow', '~> 2.1.5'

  target 'Stepper' do
    project 'Stepper/Stepper.xcodeproj'
    pod 'StepperPlugin', path: 'StepperPlugin.podspec'

    target 'StepperTests' do
      inherit! :search_paths
    end
  end

  target 'StepperPlugin' do
    project 'StepperPlugin/StepperPlugin.xcodeproj'

    target 'StepperPluginTests' do
      inherit! :search_paths
    end
  end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ""
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end

