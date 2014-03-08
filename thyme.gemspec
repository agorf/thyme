require 'date'

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'thyme/version'

Gem::Specification.new do |gem|
  gem.name          = 'thyme'
  gem.version       = Thyme::VERSION

  gem.authors       = ['Aggelos Orfanakos']
  gem.date          = Date.today
  gem.email         = ['me@agorf.gr']
  gem.homepage      = 'http://agorf.gr/'

  gem.description   = %q{A simple gallery}
  gem.summary       = gem.description

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map {|f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'dm-sqlite-adapter'
  gem.add_runtime_dependency 'data_mapper'
  gem.add_runtime_dependency 'mini_exiftool'
  gem.add_runtime_dependency 'mini_magick'
  gem.add_runtime_dependency 'sinatra'
  gem.add_runtime_dependency 'rake'

  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'thin'
  gem.add_development_dependency 'rerun'
end
