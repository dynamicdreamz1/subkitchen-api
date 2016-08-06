uri = URI.parse(ENV['REDISTOGO_URL'] || 'redis://localhost:6379')
limit = URI.parse(ENV['REDISTOGO_LIMIT'] || 2
$redis = ConnectionPool::Wrapper.new(size: limit, timeout: 3) { Redis.new(url: uri) }
