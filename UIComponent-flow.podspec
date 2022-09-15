#
# pod trunk push UIComponent-flow.podspec --allow-warnings --sources='https://github.com/CocoaPods/Specs.git'

# Be sure to run `pod lib lint UIComponent-flow.podspec --allow-warnings --sources='https://github.com/CocoaPods/Specs.git' ' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'UIComponent-flow'
  s.version          = '1.0.4'
  s.summary          = 'UIComponent 小修改'
  s.module_name = "UIComponent"
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/NeverAgain11/UIComponent'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ljk' => 'liujk0723@gmail.com' }
  s.source           = { :git => 'https://github.com/NeverAgain11/UIComponent.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
#  s.swift_version = '5'
  s.source_files = 'Sources/**/*'

  s.dependency 'BaseToolbox', '~> 1.0.4'

end

