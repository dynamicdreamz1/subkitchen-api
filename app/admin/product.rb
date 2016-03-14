ActiveAdmin.register Product do
  permit_params :design
  config.batch_actions = false
  actions :index, :show, :update, :edit


  scope :all, default: true
  scope :ready_to_print, default: false

  filter :published
  filter :name_cont, as: :string, label: 'Name'
  filter :product_template_product_type_cont, as: :select, collection: ProductTemplate.pluck(:product_type).map(&:humanize)
  filter :price

  index do
    column('Image') do |product|
      attachment_image_tag(product, :image, :fit, 50, 50)
    end
    column(:author)
    column(:name)
    column(:published)
    column(:price)
    column('Type') { |product| product.product_template.product_type.humanize }
    actions
  end


  form do |f|
    f.inputs 'Product Design', multipart: true do
      f.input :design, as: :refile
      f.actions
    end
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
      row('Design'){ attachment_image_tag(product, :design, :fit, 50, 50) }
    end
  end
end
