#
# Be sure to run `pod lib lint GioDH.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'GioDH'
    s.version          = '0.1.1'
    s.summary      = "A tiny diffie helman key exchange library using CommonCrypto."
  s.description      = <<-DESC
A tiny library for swift which make key exchange wraps CommonCrypto and inspired by SwCrypt lib.
                       DESC

  s.homepage         = 'https://github.com/sercan5534/GioDH'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Sercan Özen' => 'sozen@netas.com.tr' }
  s.source           = { :git => 'https://github.com/sercan5534/GioDH.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'GioDH/Classes/**/*'
  
  # s.resource_bundles = {
  #   'GioDH' => ['GioDH/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'BigInt', '~> 1.3.0'
end
