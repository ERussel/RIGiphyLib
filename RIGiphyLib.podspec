#
# Be sure to run `pod lib lint RIGiphyLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "RIGiphyLib"
  s.version          = "1.0.1"
  s.summary          = "Wrapper around Giphy service with included UI."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = "This CocoaPod provides UI and API wrapper to view and pick GIFs from Giphy service."

  s.homepage         = "https://github.com/ERussel/RIGiphyLib"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Russel" => "emkil.russel@gmail.com" }
  s.source           = { :git => "https://github.com/ERussel/RIGiphyLib.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resources = 'GiphyResources.bundle'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'FLAnimatedImage', '~> 1.0'
  s.dependency 'MBProgressHUD', '~> 0.9.1'
  s.dependency 'AsyncDisplayKit'
end
