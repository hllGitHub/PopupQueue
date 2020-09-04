Pod::Spec.new do |spec|
  spec.name         = "JHPopupQueue"
  spec.version      = "0.0.1beta"
  spec.summary      = "弹框事件队列管理"
  spec.description  = "这个库提供了一个queue，去根据优先级以及页面需要管理各个弹框事件，实现自动化，并且有效解决了各个事件之间的冲突"

  spec.homepage     = "https://github.com/hllGitHub/PopupQueue"
  spec.license      = "MIT"

  spec.author       = { "liangliang.hu" => "hllfj922@gmail.com" }

  spec.module_name = 'JHPopupQueue'
  spec.platform     = :ios, "10.0"
  spec.swift_versions = ['4', '5']

  spec.source       = { :git => "https://github.com/hllGitHub/PopupQueue.git", :tag => "#{spec.version}" }
  spec.source_files  = "Source/*.swift"
end