if File.exist?(config = Rails.root.join('config/redis.yml'))
  config = YAML::load File.read(config)
  Redis.current = Redis.new(config[Rails.env])
end