module RedisCounterGetters
  def sales_count
    $redis.get("user_#{id}_sales_counter").to_i
  end

  def sales_weekly
    $redis.get("user_#{id}_sales_weekly").to_i
  end

  def likes_count
    $redis.get("user_#{id}_likes_counter").to_i
  end

  def likes_weekly
    $redis.get("user_#{id}_likes_weekly").to_i
  end

  def published_count
    $redis.get("user_#{id}_published_counter").to_i
  end

  def published_weekly
    $redis.get("user_#{id}_published_weekly").to_i
  end

  def earnings_count
    $redis.get("user_#{id}_earnings_counter").to_i
  end

  def earnings_weekly
    $redis.get("user_#{id}_earnings_weekly").to_i
  end
end