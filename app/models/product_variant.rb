class ProductVariant < ActiveRecord::Base
  belongs_to :product

  after_update SendOrderIfItemsReady.new, if: :design_id_changed?
  after_save SendOrderIfItemsReady.new, if: :design_id

  validates :size, uniqueness: { scope: :product_id }

  attachment :design

  def design_s3_url
    "https://#{Figaro.env.s3_bucket}.s3.amazonaws.com/store/#{design_id}"
  end
end
