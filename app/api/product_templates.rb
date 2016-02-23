module ProductTemplates
  class Api < Grape::API
    resources :product_templates do
      desc 'create product template'
      params do
        requires :price, type: BigDecimal
        requires :product_type, type: String
        requires :size, type: String
        requires :size_chart, type: File
      end
      post do
        authenticate!
        size_chart = ActionDispatch::Http::UploadedFile.new(params.size_chart)
        product_template = ProductTemplate.new(price: params.price,
                                                    product_type: params.product_type,
                                                    size: params.size,
                                                    size_chart: size_chart)
        unless product_template.save
          status :unprocessable_entity
        end
        product_template
      end

      desc 'remove product template'
      delete ':id' do
        authenticate!
        product_template = ProductTemplate.find_by(id: params.id)
        if product_template
          product_template.delete_product_template
        else
          status :unprocessable_entity
        end
      end
    end
  end
end
