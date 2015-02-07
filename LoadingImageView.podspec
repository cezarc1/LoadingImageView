Pod::Spec.new do |s|
  s.name = 'LoadingImageView'
  s.version = '0.1.2'
  s.license = 'MIT'
  s.summary = 'Loading Indicator for UIImageView, written in Swift'
  s.homepage = 'https://github.com/ggamecrazy/LoadingImageView'
  s.social_media_url = 'https://twitter.com/ggamecrazy'
  s.authors = { 'Cezar Cocu' => 'me@cezarcocu.com' }
  s.source = { :git => 'https://github.com/ggamecrazy/LoadingImageView.git', :tag => '0.1.2' }
  s.requires_arc = true
  s.ios.framework = 'UIKit'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Source/*.swift'
end
