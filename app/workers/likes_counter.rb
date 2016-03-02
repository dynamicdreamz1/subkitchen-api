class LikesCounter
  include Sidekiq::Worker

  def perform(like_id, quantity)
    user = get_user(like_id)
    count = get_counter(user)
    if (count + quantity) >= 0
      increment(quantity, user)
      percentage = calculate_percentage(user, count, quantity)
      set_weekly(user, percentage)
    end
  end

  private

  def increment(quantity, user)
    $redis.incrby("user_#{user.id}_likes_counter", quantity)
  end

  def set_weekly(user, percentage)
    $redis.set("user_#{user.id}_likes_weekly", percentage)
  end

  def calculate_percentage(user, count, quantity)
    count + quantity == 0 ? 0 : (user.likes_count_weekly * 100) / (count + quantity)
  end

  def get_counter(user)
    $redis.get("user_#{user.id}_likes_counter").to_i
  end

  def get_user(like_id)
    like = Like.find_by(id: like_id)
    like.likeable.author
  end
end
