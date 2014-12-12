Pod::Spec.new do |s|
  s.name         = "NORMarkdownParser"
  s.version      = "0.1.1"
  s.summary      = "A simple Markdown to NSAttributedString parser using hoedown"

  s.description  = <<-DESC
                   A lightweight wrapper around hoedown, a fast C Markdown parser. The goal is to produce NSAttributedStrings which are suitable for presentation in custom controls or places where full-blown HTML rendering is not desired, such as chat/comment/posting interfaces in applications.
                   DESC

  s.homepage     = "https://github.com/henrinormak/NORMarkdownParser"
  s.license      = { :type => 'MIT' }
  s.author       = { "Henri Normak" => "henri.normak@gmail.com" }

  s.platform     = :ios
  s.platform     = :ios, '7.0'

  s.source       = { :git => "https://github.com/henrinormak/NORMarkdownParser.git", :tag => s.version, :submodules => true }
  s.frameworks = 'Foundation'
  s.requires_arc = true

  s.source_files = 'hoedown/**/*.{h,c}', 'NORMarkdownParser/*.{h,m}'
end
