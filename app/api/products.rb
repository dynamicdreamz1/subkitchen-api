module Products
  class Api < Grape::API
    resources :products do

      helpers do
        def author?(current_user, product)
          if current_user
            current_user == product.author
          else
            false
          end
        end
      end

      desc 'return all products'
      params do
        optional :page, type: Integer, default: 1
        optional :per_page, type: Integer, default: 30
        optional :sorted_by, type: String, default: 'created_at_desc'
        optional :with_product_type, type: Array[String]
        optional :with_price_range, type: Array[Integer]
        optional :tag_filter, type: String
      end
      get do
        filterrific = Filterrific::ParamSet.new(Product, {sorted_by: params.sorted_by,
                                                with_price_range: params.with_price_range,
                                                with_product_type: params.with_product_type})
        products = Product.filterrific_find(filterrific).page(params.page).per(params.per_page)
        ProductListSerializer.new(products).as_json
      end

      desc 'return product by id'
      get ':id' do
        product = Product.find_by(id: params.id)
        if product
          ProductSerializer.new(product).as_json
        else
          error!({errors: {base: ['no product with given id']}}, 422)
        end
      end

      desc 'create product'
      params do
        requires :name, type: String
        requires :product_template_id, type: Integer
        requires :description, type: String
        requires :image, type: File
        requires :published, type: Boolean
      end
      post do
        if CheckProductImageSize.new(params.image)
          product = CreateProduct.new(params, current_user).call
          if product.valid?
            product.save
          else
            status :unprocessable_entity
          end
          ProductSerializer.new(product).as_json
        else
          error!({errors: {base: ['image is too small']}}, 422)
        end
      end

      desc 'remove product'
      delete ':id' do
        product = Product.find_by(id: params.id)
        if product
          DeleteResource.new(product).call
        else
          error!({errors: {base: ['no product with given id']}}, 422)
        end
        ProductSerializer.new(product).as_json
      end

      desc 'publish product'
      params do
        requires :product_id, type: Integer
      end
      post 'publish' do
        authenticate!
        product = Product.find_by(id: params.product_id)
        if product
          if PublishProduct.new(product, current_user).call
            ProductSerializer.new(product).as_json
          else
            error!({errors: {base: ['cannot publish not own product']}}, 422)
          end
        else
          error!({errors: {base: ['no product with given id or user is not an author']}}, 422)
        end
      end

      desc 'like product'
      params do
        requires :product_id, type: Integer
      end
      post 'like' do
        authenticate!
        product = Product.find_by(id: params.product_id)
        LikeProduct.new(product, current_user).call
        if product
          if !author?(current_user, product)
            unless LikeProduct.new(product, current_user).call
              error!({errors: {base: ['cannot like product more than once']}}, 422)
            end
          else
            error!({errors: {base: ['cannot like own product']}}, 422)
          end
        else
          error!({errors: {base: ['no product with given id']}}, 422)
        end
      end

      desc 'unlike product'
      params do
        requires :product_id, type: Integer
      end
      post 'like' do
        authenticate!
        product = Product.find_by(id: params.product_id)
        if product
          if product.likes.empty?
            unless UnlikeProduct.new(product, current_user).call
              error!({errors: {base: ['no like with given user id']}}, 422)
            end
          else
            error!({errors: {base: ['cannot unlike not liked product']}}, 422)
          end
        else
          error!({errors: {base: ['no product with given id']}}, 422)
        end
      end
    end
  end
end
