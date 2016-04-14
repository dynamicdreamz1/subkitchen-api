uri = URI.parse(ENV['REDISTOGO_URL'] || 'redis://localhost:6379')
$redis = ConnectionPool::Wrapper.new(size: 5, timeout: 3) { Redis.new(url: uri) }
