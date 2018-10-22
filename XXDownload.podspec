Pod::Spec.new do |s|
  s.name             = 'XXDownload'
  s.version          = '0.2.3'
  s.summary          = 'This is a download tool'
  s.description      = 'description'
  s.homepage         = 'https://github.com/XXDownload/XXDownload'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yangzi' => '595919268@qq.com' }
  s.source           = { :git => 'https://github.com/XXDownload/XXDownload.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'XXDownload/Classes/**/*'

end
