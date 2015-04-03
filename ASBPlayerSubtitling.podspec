Pod::Spec.new do |s|
  s.name = "ASBPlayerSubtitling"
  s.version = "0.1"
  s.license = 'MIT'
  s.summary = "AVPlayer subtitle behavior for iOS."
  s.authors = {
    "Philippe Converset" => "pconverset@autresphere.com"
  }
  s.homepage = "https://github.com/autresphere/ASBPlayerSubtitling"
  s.source = {
    :git => "https://github.com/autresphere/ASBPlayerSubtitling.git",
    :tag => "0.1"
  }
  s.platform = :ios, '7.0'
  s.source_files = 'ASBPlayerSubtitling/*.{h,m}'
  s.frameworks = 'UIKit', 'Foundation', 'CoreGraphics', 'AVFoundation'
  s.requires_arc = true
end