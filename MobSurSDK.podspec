Pod::Spec.new do |s|
  s.name             = 'MobSurSDK'
  s.version          = '1.0.3'
  s.summary          = 'Implement surveys in your app with just a few lines of code.'

  s.description      = <<-DESC
This is the iOS SDK for the MobSur SaaS. You can view all the features and documentation at mobsur.com
With this SDK you can implement surveys in your app with just a few lines of code.
All the other work is done by the marketing team in the MobSur dashboard.
                       DESC

  s.homepage         = 'https://mobsur.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Modified MIT', :file => 'LICENSE' }
  s.author           = { 'Lachezar Todorov' => 'lachezar.todorov@edentechlabs.io' }
  s.source           = { :git => 'https://github.com/eden-tech-labs/MobSur_iOS_SDK.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform         = :ios, '14.0'
  s.swift_version    = '4.0'

  s.source_files            = 'Sources/**/*'
  s.ios.vendored_frameworks = 'MobSur_iOS_SDK.xcframework'

  s.frameworks = 'UIKit'

end
