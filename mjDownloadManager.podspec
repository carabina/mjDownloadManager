Pod::Spec.new do |s|
  s.name         = "mjDownloadManager"
  s.version      = "0.0.7"
  s.summary      = "A simple download helper"
  s.homepage     = "https://github.com/blackho1e/mjDownloadManager"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Minju Kang" => "blackdole@naver.com" }

  s.platform     = :ios
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/blackho1e/mjDownloadManager.git", :tag => "0.0.7" }
  s.source_files  = "Classes/*"
  s.requires_arc = true
  s.dependency 'Alamofire', '~> 3.0'
end
