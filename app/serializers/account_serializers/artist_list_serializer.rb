class ArtistListSerializer
  def as_json(options = {})
    data = {
        artists: serialized_artists,
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
      image_url: (artist.profile_image_url || image_url(artist)),
      handle: artist.handle,
      company: artist.company,
      designs: artist.products.count,
      likes: artist.likes_count,
      verified: artist.status,
      location: nil,
      website: nil,
      bio: nil,
      shop_banner: artist.shop_banner_url,
      promoted:  nil,
      followers: nil,
      following: nil }
  end

  def image_url(artist)
    if artist.profile_image_url
      Figaro.env.app_host.to_s + Refile.attachment_url(artist, :profile_image, :fill, 200, 200, format: :png)
    else
      if artist.provider == 'facebook' && artist.uid
        return "https://graph.facebook.com/#{artist.uid}/picture?width=200"
      end
      nil
    end
  end
end