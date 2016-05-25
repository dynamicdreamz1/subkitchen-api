class PublishedCounter
  include Sidekiq::Worker

  def perform(product_id, quantity)
    user = get_user(product_id)
    return unless (get_counter(user) + quantity) >= 0
    increment(quantity, user)
    percentage = calculate_percentage(user)
    set_weekly(user, percentage)
  end

  private

  def increment(quantity, user)
    $redis.incrby("user_#{user.id}_published_counter", quantity)
  end

  def set_weekly(user, percentage)
    $redis.set("user_#{user.id}_published_weekly", percentage)
  end

  def calculate_percentage(user)
    count = get_counter(user)
    return 0 if count == 0
    (published_count_weekly(user) * 100) / count
  end

  def get_counter(user)
    $redis.get("user_#{user.id}_published_counter").to_i
  end

  def get_user(product_id)
    Product.find_by(id: product_id).author
  end

  def published_count_weekly(user)
    user.products.select { |product| product.published_at > 1.week.ago }.count
  end
end
