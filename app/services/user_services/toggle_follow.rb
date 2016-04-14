class ToggleFollow
  def call
    toggle
  end

  private

  attr_accessor :current_user, :artist

  def initialize(current_user, artist)
    @artist = artist
    @current_user = current_user
  end

  def toggle
    @like = Like.where(likeable: artist, user: current_user).first
    @like ? unfollow : follow
  end

  def unfollow
    @like.destroy
  end

  def follow
    Like.create!(likeable: artist, user: current_user)
  end
end