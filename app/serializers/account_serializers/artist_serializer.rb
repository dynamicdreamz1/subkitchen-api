class ArtistSerializer
  def as_json(options = {})
    data = {
      artist: { id: artist.id,
                name: artist.name,
                image_url: (artist.profile_image_url || image_url),
                handle: artist.handle,
                company: artist.company,
                designs: artist.products.count,
                likes: artist.likes_count } }

    data[:errors] = artist.errors.to_h if artist.errors.any?

    data.as_json(options)
  end

  private

  attr_reader :artist

  def initialize(artist)
    @artist = artist
  end

  def image_url
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
