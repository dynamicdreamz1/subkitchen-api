ActiveAdmin.register ProductTemplate do
  config.sort_order = 'id_asc'
  permit_params :price,
    :product_type,
    :size_chart,
    :profit,
    :is_deleted,
    :template_image,
    :template_mask,
    :sizes_raw, template_variants_attributes: [:name, :color_id, :template_color_image]
  config.filters = false
  config.batch_actions = false
  actions :index, :show, :edit, :new, :create, :update, :delete

  scope :all
  scope :deleted

  member_action :delete, method: :put do
    resource.update(is_deleted: true)
    resource.products.map { |p| p.update(is_deleted: true) }
    redirect_to admin_product_templates_path, notice: 'Template Deleted'
  end

  member_action :restore, method: :put do
    template = ProductTemplate.unscoped.where(id: params[:id]).first
    template.update(is_deleted: false)
    template.products.unscoped.map { |p| p.update(is_deleted: false) }
    redirect_to admin_product_templates_path, notice: 'Template Restored'
  end

  index do
    column(:id)
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
          link_to('Delete', delete_admin_product_template_path(template), method: :put,
                  data: { confirm: 'Are you sure? If you delete this template,
                                    all the products related to this template will be deleted' })
      end
    end
  end

  show do |template|
    tabs do
      tab('Overview') do
        attributes_table do
          row('Image') { attachment_image_tag(template, :template_image, :fit, 150, 150) }
          row('Image Mask') { attachment_image_tag(template, :template_mask, :fit, 150, 150) }
          row(:product_type)
          row(:profit)
          row(:created_at)
          row(:price)
          row(:size)
          row('Size Chart') { attachment_image_tag(template, :size_chart, :fit, 150, 150) }
          row(:is_deleted)
        end
      end

      tab('Variants') do
        table_for template.template_variants do
          column('Name', &:name)
          column('Color') { |variant| variant.color.try(:name) }
          column('Color Preview') { |variant| "<div style='width:50px; height:50px; background-color:#{variant.color.try(:color_value)}'></div>".html_safe }
          column('Template Preview') { |variant| attachment_image_tag(variant, :template_color_image, :fit, 150, 150) }
        end
      end
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
    end
    f.inputs 'Variants' do
      f.has_many :template_variants do |v|
        v.input :name
        v.input :color, collection: Color.all
        v.input :template_color_image, as: :refile
      end
    end

    f.actions
  end
end
