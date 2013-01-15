ENV["RAILS_ENV"] = 'test'

require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'

  load "#{Rails.root}/db/schema.rb"
end

Spork.each_run do
  require 'blueprints'
  
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| load f}
  Dir[Rails.root.join("app/models/**/*.rb")].each {|m| load m}

  RSpec.configure do |config|
    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.clean_with(:truncation)

      Redis.current.flushdb
    end

    config.before(:all) do
      DatabaseCleaner.start
    end

    config.after(:all) do
      DatabaseCleaner.clean
      Redis.current.flushdb
    end

    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    config.order = "random"
  end
end
