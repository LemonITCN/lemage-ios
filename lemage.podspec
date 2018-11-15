Pod::Spec.new do |s|
    s.name         = "lemage"
    s.version      = "1.0.4"
    s.ios.deployment_target = '8.0'
    s.summary      = "lemage相册浏览器"
    s.homepage     = "https://github.com/LemonITCN/lemage-ios"
    s.license              = { :type => "MIT", :file => "LICENSE" }
    s.author             = { "LemonITCN" => "306822374@qq.com" }
    s.source       = { :git => "https://github.com/LemonITCN/lemage-ios.git", :tag =>"v1.0.4" }
    s.source_files  = "lemage/lemage/*.{h,m}","lemage/lemage/**/*.{h,m}"
    s.requires_arc = true
end