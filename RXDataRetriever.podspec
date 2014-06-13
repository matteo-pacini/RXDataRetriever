Pod::Spec.new do |s|

  s.name         = "RXDataRetriever"
  s.version      = "0.1.0"
  s.summary      = "Reactive JSON RESTful client."

  s.description  = <<-DESC
                   Reactive JSON RESTful client.
                   Based on ReactiveCocoa and AFNetworking 2.x.
                   DESC

  s.homepage     = "http://github.com/Zi0P4tch0/RXDataRetriever"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Matteo Pacini" => "ispeakprogramming@gmail.com" }
  s.social_media_url   = "http://twitter.com/Zi0P4tch0"
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/Zi0P4tch0/RXDataRetriever.git", :tag => "0.1.0" }
  s.source_files  = "RXDataRetriever.{h,m}"
  s.requires_arc = true
  s.framework = 'Foundation'
  s.dependency "AFNetworking", "~> 2.3.0"
  s.dependency "ReactiveCocoa", "~> 2.3.1"
  s.compiler_flags = '-fmodules'

end
