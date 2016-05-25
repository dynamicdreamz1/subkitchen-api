class LikesCounter
  include Sidekiq::Worker

  def perform(author_id, quantity)
    user = get_user(author_id)
    return unless (get_counter(user) + quantity) >= 0
    increment(user, quantity)
    percentage = calculate_percentage(user)
    set_weekly(user, percentage)
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
    return 0 if count == 0
    (likes_count_weekly(user) * 100) / count
  end

  def get_counter(user)
    $redis.get("user_#{user.id}_likes_counter").to_i
  end

  def get_user(author_id)
    User.find(author_id)
  end

  def likes_count_weekly(user)
    Like.where(likeable_id: user.products.pluck(:id), likeable_type: 'Product')
        .where('created_at >= ?', 1.week.ago).count
  end
end
