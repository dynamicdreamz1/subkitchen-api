class LikesCounter
  include Sidekiq::Worker

  def perform(author_id, quantity)
    user = get_user(author_id)
    if (get_counter(user) + quantity) >= 0
      increment(user, quantity)
      percentage = calculate_percentage(user)
      set_weekly(user, percentage)
    end
  end

  private

  def increment(user, quantity)
    $redis.incrby("user_#{user.id}_likes_counter", quantity)
  end

  def set_weekly(user, percentage)
    $redis.set("user_#{user.id}_likes_weekly", percentage)
  end

  def calculate_percentage(user)
    count = get_counter(user)
    count == 0 ? 0 : ((likes_count_weekly(user) * 100) / count)
  end

  def get_counter(user)
    $redis.get("user_#{user.id}_likes_counter").to_i
  end

  def get_user(author_id)
    User.find(author_id)
  end

  def likes_count_weekly(user)
    count = 0
    user.products.each do |product|
      count += Like.this_week(product.id)
    end
    count
    # Like.week(products.pluck(:id), 'Product').count
  end
end
