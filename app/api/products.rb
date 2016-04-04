module Products
  class Api < Grape::API
    resources :products do

      desc 'return all products'
      params do
        optional :page, type: Integer, default: 1
        optional :per_page, type: Integer, default: 30
        optional :sorted_by, type: String, default: 'created_at_desc'
        optional :with_product_type, type: Array[String]
        optional :with_price_range, type: Array[Integer]
        optional :with_tags, type: Array[String]
      end
      get do
        filterrific = Filterrific::ParamSet.new(Product, {sorted_by: params.sorted_by,
                                                          with_price_range: params.with_price_range,
                                                          with_product_type: params.with_product_type,
                                                          with_tags: params.with_tags})
        products = Product.filterrific_find(filterrific).page(params.page).per(params.per_page)
        if products
          ProductListSerializer.new(products).as_json
        else
          error!({errors: {base: ['no products matching given criteria']}}, 404)
        end
      end

      desc 'return product by id'
      get ':id' do
        product = Product.find(params.id)
        ProductSerializer.new(product).as_json
      end

      desc 'create product'
      params do
        requires :name, type: String
        requires :product_template_id, type: Integer
        requires :description, type: String
        requires :image, type: File
        requires :published, type: Boolean
        requires :tags, type: Array[String]
      end
      post do
        product = CreateProduct.new(params, current_user).call
        if product.valid?
          product.save
        else
          error!({errors: product.errors.messages}, 422)
        end
        ProductSerializer.new(product).as_json
      end

      desc 'remove product'
      delete ':id' do
        product = Product.find(params.id)
        DeleteProduct.new(product).call
        ProductSerializer.new(product).as_json
      end

      desc 'publish product'
      params do
        requires :product_id, type: Integer
      end
      post 'publish' do
        authenticate!
        product = Product.find(params.product_id)
        if PublishProduct.new(product, current_user).call
          ProductSerializer.new(product).as_json
        else
          error!({errors: {base: ['cannot publish not own product']}}, 422)
        end
      end
    end
  end
end
