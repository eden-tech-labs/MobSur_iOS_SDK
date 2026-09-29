Pod::Spec.new do |s|
  s.name             = 'MobSurSDK'
  s.version          = '1.1.0'
  s.summary          = 'Implement surveys in your app with just a few lines of code.'

  s.description      = <<-DESC
This is the iOS SDK for the MobSur SaaS. You can view all the features and documentation at mobsur.com
With this SDK you can implement surveys in your app with just a few lines of code.
All the other work is done by the marketing team in the MobSur dashboard.
                       DESC

  s.homepage         = 'https://mobsur.com'
  s.license          = { :type => 'Modified MIT', :file => 'LICENSE' }
  s.author           = { 'Lachezar Todorov' => 'lachezar.todorov@edentechlabs.io' }
  s.source           = { :git => 'https://github.com/eden-tech-labs/MobSur_iOS_SDK.git', :tag => s.version.to_s }

  # Keep in sync with Package.swift and the framework's IPHONEOS_DEPLOYMENT_TARGET.
  s.platform         = :ios, '12.0'
  s.swift_version    = '5.0'

  s.source_files            = 'Sources/**/*'
  s.ios.vendored_frameworks = 'MobSur_iOS_SDK.xcframework'

  s.frameworks = 'UIKit', 'WebKit'

end
