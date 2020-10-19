#
# Be sure to run `pod lib lint PayMESDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PayMESDK'
  s.version          = '0.1.0'
  s.summary          = 'Đây là tóm tắt của SDK'
  s.swift_versions   = '4.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://payme.vn/'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'HuyOpen' => 'huytq@payme.vn' }
  s.source           = { :git => 'https://gitlab.com/huyopen/anotherfakeproject.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'PayMESDK/Classes/**/*'
  
  # s.resource_bundles = {
  #   'PayMESDK' => ['PayMESDK/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'WebKit', 'Foundation', 'Security'
  s.dependency 'CryptoSwift', '~> 1.0'
  s.dependency 'SwiftyRSA', '1.5'
end
