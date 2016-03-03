class LikesCounter
  include Sidekiq::Worker

  def perform(like_id, quantity)
    user = get_user(like_id)
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
    count == 0 ? 0 : ((user.likes_count_weekly * 100) / count)
  end

  def get_counter(user)
    $redis.get("user_#{user.id}_likes_counter").to_i
  end

  def get_user(like_id)
    like = Like.find_by(id: like_id)
    like.likeable.author
  end
end
