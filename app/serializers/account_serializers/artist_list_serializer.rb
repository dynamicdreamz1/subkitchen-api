class ArtistListSerializer
  def as_json(options = {})
    data = {
      users: serialized_artists,
      meta: {
        current_page: artists.current_page,
        total_pages: artists.total_pages
      }
    }

    data.as_json(options)
  end

  private

  attr_reader :artists

  def initialize(artists)
    @artists = artists
  end

  def serialized_artists
    artists.map do |artist|
      single_artist = single_artist(artist)

      single_artist[:errors] = artist.errors if artist.errors.any?
      single_artist
    end
  end

  def single_artist(artist)
    { id: artist.id,
      name: artist.name,
      image_url: artist.profile_image || image_url(artist),
      handle: artist.handle,
      company: artist.company,
      products_count: artist.products.count,
      likes_count: artist.product_likes_count,
			verified: artist.status,
			featured: artist.featured,
      location: nil,
      website: nil,
      bio: nil,
      shop_banner: artist.shop_banner,
      promoted:  nil,
      followers: nil,
      following: nil }
  end

  def image_url(artist)
		if artist.provider == 'facebook' && artist.uid
			return "https://graph.facebook.com/#{artist.uid}/picture?width=200&height=200"
		end
		nil
  end
end
