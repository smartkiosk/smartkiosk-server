$:.push File.expand_path("../lib", __FILE__)

require "mkb/version"

Gem::Specification.new do |s|
  s.name        = "mkb"
  s.version     = Mkb::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Mkb."
  s.description = "TODO: Description of Mkb."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'sidekiq'
  s.add_dependency 'composite_primary_keys'

  if RUBY_PLATFORM =~ /java/
    s.add_dependency "activerecord-jdbc-adapter", "1.2.2.1"
    s.add_dependency "activerecord-oracle_enhanced-adapter", "~> 1.4.0"
    s.add_dependency "activerecord-jdbcmssql-adapter"
  end
end
