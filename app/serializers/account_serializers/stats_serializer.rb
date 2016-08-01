class StatsSerializer
  include ApplicationHelper

  def as_json(options = {})
    data = {
      total_sales: artist.sales_count,
      total_sales_percentage: artist.sales_weekly,
      earnings: artist.earnings_count,
      earnings_percentage: artist.earnings_weekly,
      published_designs: artist.published_count,
      published_designs_percentage: artist.published_weekly,
      total_likes: artist.product_likes_count,
      total_likes_percentage: artist.product_likes_weekly
    }

    data[:errors] = artist.errors if artist.errors.any?

    data.as_json(options)
  end

  private

  attr_reader :artist

  def initialize(artist)
    @artist = artist
  end
end
