ActiveAdmin.register ProductTemplate do
  permit_params :price,
                :product_type,
                :size_chart,
                :profit,
                :is_deleted,
                :template_image
  actions :all, except: :destroy

  index do
    column('Image') do |template|
      attachment_image_tag(template, :template_image, :fit, 50, 50)
    end
    column(:product_type)
    column(:profit)
    column(:created_at)
    column(:price)
    column(:is_deleted)
    actions
  end

  show do |template|
    attributes_table do
      row('Image'){ attachment_image_tag(template, :template_image, :fit, 150, 150) }
      row(:product_type)
      row(:profit)
      row(:created_at)
      row(:price)
      row('Size Chart'){ attachment_image_tag(template, :size_chart, :fit, 150, 150) }
      row(:is_deleted)
    end
  end

  form do |f|
    f.inputs 'Template', multipart: true do
      f.input :template_image, as: :refile
      f.input :size_chart, as: :refile
      f.input :product_type
      f.input :price
      f.actions
    end
  end
end
