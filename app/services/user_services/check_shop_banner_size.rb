class CheckShopBannerSize
  def call
    check_size
  end

  private

  def initialize(params_image)
    @path = ActionDispatch::Http::UploadedFile.new(params_image).tempfile.path
    @type = params_image.type
  end

  def check_size
    if image?
      image.width > 100 && image.height > 100
    else
      true
    end
  end

  def image
    MiniMagick::Image.new(@path)
  end

  def image?
    %w(image/jpg image/jpeg image/png).include? @type
  end
end