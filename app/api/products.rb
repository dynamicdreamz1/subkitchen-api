module Products
  class Api < Grape::API
    resources :products do

      helpers do
        def is_author?(current_user, product)
          product.author == current_user
        end

        def author?(current_user, product)
          if current_user
            current_user == product.author
          else
            false
          end
        end
      end

      desc 'return all products'
      get do
        page = params.page.to_i != 0? params.page : 1
        per_page = params.per_page.to_i != 0? params.per_page : 30
        products = Product.page(page).per(per_page)
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
        if product && is_author?(current_user, product)
          product.published = true
          product.published_at = DateTime.now
          unless product.save
            status :unprocessable_entity
          end
          ProductSerializer.new(product).as_json
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
        if product
          if !author?(current_user, product)
            product.likes.new(user_id: current_user.id)
            if product.valid?
              product.save
            else
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
            like = product.likes.find_by(user_id: current_user.id)
            if like
              like.destroy
            else
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
