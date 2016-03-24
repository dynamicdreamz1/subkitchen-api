module ProductTemplates
  class Api < Grape::API
    resources :product_templates do

      desc 'return all product templates'
      get do
        ProductTemplateListSerializer.new(ProductTemplate.all).as_json
      end
    end
  end
end
