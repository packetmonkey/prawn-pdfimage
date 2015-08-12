Gem::Specification.new do |s|
  s.name = 'prawn-pdfimage'
  s.version = '0.0.1'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Evan Sharp']
  s.license = 'MIT'
  s.summary = "Add PDF 'images' as images in prawn documents"
  s.require_path = 'lib'
  s.add_dependency 'prawn', '>= 0.15', '< 3.0'
  s.add_dependency 'pdf-reader', '1.3.3'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop'
  s.files = Dir.glob('{ext,lib,test}/**/*') + %w(README.markdown Rakefile)
end
