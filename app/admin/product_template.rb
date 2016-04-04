ActiveAdmin.register ProductTemplate do
  permit_params :price,
                :product_type,
                :size_chart,
                :profit,
                :is_deleted,
                :template_image,
                :template_mask,
                :sizes_raw
  config.filters = false
  config.batch_actions = false
  actions :index, :show, :edit, :new, :create, :update, :delete

  scope :all
  scope :deleted

  member_action :delete, method: :put do
    resource.update(is_deleted: true)
    resource.products.map{ |p| p.update(is_deleted: true) }
    redirect_to admin_product_templates_path, notice: 'Template Deleted'
  end

  member_action :restore, method: :put do
    template = ProductTemplate.unscoped.where(id: params[:id]).first
    template.update(is_deleted: false)
    template.products.unscoped.map{ |p| p.update(is_deleted: false) }
    redirect_to admin_product_templates_path, notice: 'Template Restored'
  end

  index do
    column('Image') do |template|
      attachment_image_tag(template, :template_image, :fit, 50, 50)
    end
    column('Image Mask') do |template|
      attachment_image_tag(template, :template_mask, :fit, 50, 50)
    end
    column(:product_type)
    column(:profit)
    column(:created_at)
    column(:price)
    actions defaults: false do |template|
      if template.is_deleted
        link_to('Restore', restore_admin_product_template_path(template), method: :put)
      else
        link_to('View', admin_product_template_path(template), method: :get) + ' ' +
        link_to('Edit', edit_admin_product_template_path(template), method: :get) + ' ' +
        link_to('Delete', delete_admin_product_template_path(template), method: :put, data: {confirm: 'Are you sure? If you delete this template, all the products related to this template will be deleted'})
      end
    end
  end

  show do |template|
    attributes_table do
      row('Image'){ attachment_image_tag(template, :template_image, :fit, 150, 150) }
      row('Image Mask'){ attachment_image_tag(template, :template_mask, :fit, 150, 150) }
      row(:product_type)
      row(:profit)
      row(:created_at)
      row(:price)
      row(:size)
      row('Size Chart'){ attachment_image_tag(template, :size_chart, :fit, 150, 150) }
      row(:is_deleted)
    end
  end

  form do |f|
    f.inputs 'Template', multipart: true do
      f.input :template_image, as: :refile
      f.input :template_mask, as: :refile
      f.input :size_chart, as: :refile
      f.input :product_type
      f.input :price
      f.input :sizes_raw, as: :text
      f.actions
    end
  end
end
