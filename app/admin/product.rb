ActiveAdmin.register Product do
  actions :index, :show

  index do
    column('Image') do |product|
      attachment_image_tag(product, :image, :fit, 50, 50)
    end
    column(:author)
    column(:name)
    column(:published)
    column(:price)
    actions
  end

  show do |product|
    attributes_table do
      row('Image'){ attachment_image_tag(product, :image, :fit, 50, 50) }
      row('Date') { product.created_at }
      row(:author)
      row(:name)
      row(:published)
      row(:price)
      row('Sold'){ product.order_items_count }
      row('Likes'){ product.likes_count }
    end
  end
end
