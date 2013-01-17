namespace :db do
  desc 'Remove and install new database from scratch'
  task :install => :environment do
    puts "Clearing Redis"
    Redis.current.flushdb

    puts "Droping all tables..."
    # Requiring every possible model
    [File.expand_path('../../../', __FILE__), Rails.root.to_s].uniq.each do |root|
      Dir["#{root}/app/models/**"].each{|x| require x; }
    end

    tables = ActiveRecord::Base.connection.tables

    ActiveRecord::Base.subclasses.map{|x| x.table_name}.each do |x|
      ActiveRecord::Base.connection.drop_table x if tables.include? x
      puts "#{x} droped;"
    end

    ActiveRecord::Base.connection.drop_table "schema_migrations"
    puts

    puts "Running migrations..."
    Rake::Task["db:migrate"].invoke

    puts "Running seeds..."
    Rake::Task["db:seed"].invoke
  end
end