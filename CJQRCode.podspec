
Pod::Spec.new do |s|

  s.name         = "CJQRCode"
  s.version      = "1.0.2"
  s.summary      = "Qr code tools."

  s.description  = "Utility class projects related to qr code"
  s.homepage     = "https://github.com/dreamCC/CJQRCode"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "dreamCC" => "568644031@qq.com" }
  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/dreamCC/CJQRCode.git", :tag => s.version }

  s.source_files  = "CJQRCode"

end
