namespace :db do
  desc 'Remove and install new database from scratch'
  task :install => :environment do
    puts "Clearing Redis"
    Redis.current.flushdb

    puts "Droping all tables..."
    ActiveRecord::Base.connection.tables.each do |x|
      ActiveRecord::Base.connection.drop_table x
      puts "#{x} droped;"
    end
    puts

    Rake::Task["db:migrate"].invoke
    puts "Running seeds..."
    Rake::Task["db:seed"].invoke
  end
end
