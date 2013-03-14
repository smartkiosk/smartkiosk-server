lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'smartkiosk/server/version'

Gem::Specification.new do |gem|
  gem.name          = 'smartkiosk-server'
  gem.version       = Smartkiosk::Server::VERSION
  gem.authors       = ['Boris Staal', 'Sergey Gridasov']
  gem.email         = ['boris@roundlake.ru', 'grindars@gmail.com']
  gem.description   = %q{Smartkiosk server application}
  gem.summary       = gem.description
  gem.homepage      = 'https://github.com/smartkiosk/smartkiosk-server'
  gem.files         = `git ls-files`.split($/)

  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'rails', '= 3.2.12'
  gem.add_dependency 'matrioshka', '>= 0.1.1'

  gem.post_install_message = "Please run `rake smartkiosk_server:link` to finish the installation."
end
