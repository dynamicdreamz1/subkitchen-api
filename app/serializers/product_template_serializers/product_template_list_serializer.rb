class ProductTemplateListSerializer

  def as_json(options={})
    data = {
        product_templates: serialized_product_templates,
    }

    data.as_json(options)
  end

  private

  attr_accessor :product_templates

  def initialize(product_templates)
    @product_templates = product_templates
  end

  def serialized_product_templates
    product_templates.map do |product_template|
      single_product_template = single_product_template(product_template)

      single_product_template[:errors] = product_template.errors if product_template.errors.any?
      single_product_template
    end
  end

  def single_product_template(product_template)
    {
        id: product_template.id,
        price: product_template.price,
        size: product_template.size,
        template_image: Figaro.env.app_host + Refile.attachment_url(product_template, :template_image, :fill, 200, 200, format: :png),
        template_image_large: Figaro.env.app_host + Refile.attachment_url(product_template, :template_image, :fill, 1024, 1024, format: :png),
        size_chart: Figaro.env.app_host + Refile.attachment_url(product_template, :size_chart, :fill, 400, 200, format: :png),
        product_type: product_template.product_type,
        profit: product_template.profit,
    }
  end
end
