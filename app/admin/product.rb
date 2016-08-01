ActiveAdmin.register Product do
  config.sort_order = 'id_asc'
  permit_params :design, :name, :author_id, :description, :product_template_id,
                :uploaded_image, :preview, :published, :published_at, :tag_list
  actions :all, except: [:destroy, :new, :create]

  scope :all
  scope :ready_to_print
  scope :waiting
	scope :deleted
	scope :featured_products

  filter :published
  filter :name_cont, as: :string, label: 'Name'
  filter :product_template_product_type_cont, as: :select, collection: proc { ProductTemplate.pluck(:product_type) }
  filter :price

  member_action :delete, method: :put do
    resource.update(is_deleted: true)
    redirect_to admin_products_path, notice: 'Product Deleted'
	end

	batch_action :feature do |ids|
		products = Product.published_all.where(id: ids)
		notice = if products.empty?
			'Select at least one product'
		else
			products.each{ |product| product.update(featured: true) }
			'Successfully added to featured products list'
		end
		redirect_to admin_products_path(scope: 'featured_products'), notice: notice
	end

	batch_action :stop_featuring do |ids|
		products = Product.published_all.where(id: ids, featured: true)
		notice = if products.empty?
			'Select at least one featured product'
		else
			products.each{ |product| product.update(featured: false) }
			'Successfully deleted from featured products list'
		end
		redirect_to admin_products_path(scope: 'featured_products'), notice: notice
	end

  index do
		selectable_column
		column(:id)
    column('Image') do |product|
      product.image ? attachment_image_tag(product, :image, :fit, 50, 50) : product.uploaded_image
    end
    column('Preview') do |product|
      attachment_image_tag(product, :preview, :fit, 50, 50)
    end
    column('Author') do |product|
      if product.author
        link_to product.author.name, admin_user_path(product.author_id)
      end
    end
    column(:name)
		column(:published)
    column(:price)
    column('Type') { |product| product.product_template.product_type }
    actions defaults: false do |product|
      unless product.is_deleted
        link_to('View', admin_product_path(product), method: :get) + ' ' +
          link_to('Edit', edit_admin_product_path(product), method: :get) + ' ' +
          link_to('Delete', delete_admin_product_path(product), method: :put, data: { confirm: 'Are you sure?' })
      end
    end
  end

  form do |f|
    f.inputs 'Product Design', multipart: true do
      f.input :design, as: :refile
      if f.object.new_record?
				f.input :image, as: :refile
        f.input :preview, as: :refile
        f.input :name
        f.input :description
        f.input :author, collection: User.artists
        f.input :product_template, collection: Hash[ProductTemplate.all.map { |t| [t.product_type, t.id] }]
        f.input :published, input_html: { value: true }, as: :hidden
        f.input :published_at, input_html: { value: DateTime.now }, as: :hidden
        f.input :tag_list, as: :tags
      end
      f.actions
    end
  end

  show do |product|
    attributes_table do
      row('Image') { product.image ? attachment_image_tag(product, :image, :fit, 50, 50) : product.uploaded_image }
      row('Preview') { attachment_image_tag(product, :preview, :fit, 50, 50) }
      row('Date') { product.created_at }
      row(:author)
      row(:name)
      row('Tags') { product.tag_list }
      row(:published)
      row(:price)
      row('Sold') { product.order_items_count }
      row('Likes') { product.likes_count }
      row('Design') { link_to 'Download', product.design_url }
    end
  end
end
