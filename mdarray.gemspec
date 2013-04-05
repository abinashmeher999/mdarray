require 'rubygems/platform'

require_relative 'version'


Gem::Specification.new do |gem|

  gem.name    = $gem_name
  gem.version = $version
  gem.date    = Date.today.to_s

  gem.summary     = "Multi dimensional array similar to narray and numpy."
  gem.description = <<-EOF 
"Multi dimensional array similar to Masahiro Tanaka's narray and numpy.  
It is specifically targeted to JRuby as it uses Java-NetCDF library as base Array."
EOF

  gem.authors  = ['Rodrigo Botafogo']
  gem.email    = 'rodrigo.a.botafogo@gmail.com'
  gem.homepage = 'http://github.com/rbotafogo/mdarray'

  gem.add_dependency('rake')
  gem.add_development_dependency('rspec', [">= 2.0.0"])
  gem.add_development_dependency('simplecov')
  gem.add_development_dependency('yard')
  gem.add_development_dependency('kramdown')

  # ensure the gem is built out of versioned files
  gem.files = Dir['Rakefile', 'version.rb', '{lib,test}/**/*.rb', '{bin,man,spec,vendor}/**/*', 
                  'README*', 'LICENSE*'] # & `git ls-files -z`.split("\0")

  gem.test_files = Dir['test/*.rb']

  gem.platform='java'

end
