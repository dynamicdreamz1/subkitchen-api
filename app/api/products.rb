module Products
  class Api < Grape::API
    helpers do
      def price_range(range)
        return unless range
        array_range = range[0].split(', ').map(&:to_i)
        Range.new(*array_range)
      end

      def themes_invalid(params)
        themes = Config.themes.downcase.split(', ')
        params.published  && (!params.tags || (themes - params.tags) == themes)
			end
    end

    resources :order_items do
      desc 'return ordered product items by date of purchase'
      params do
        optional :page, type: Integer, default: 1
        optional :per_page, type: Integer, default: 5
        requires :author_id, type: Integer
      end
      get do
        order_items = OrderItem.last_sales(params.author_id).page(params.page).per(params.per_page)
        OrderItemListSerializer.new(order_items).as_json
      end
    end

    resources :products do
      desc 'return all products'
      params do
        optional :page, type: Integer, default: 1
        optional :per_page, type: Integer, default: 30
        optional :search_query, type: String
        optional :sorted_by, type: String, default: 'created_at_desc'
        optional :product_type, type: Array[String]
        optional :price_range, type: Array[String]
        optional :tags, type: Array[String]
        optional :author_id, type: Integer
        optional :only_published, type: Boolean, default: true
        optional :featured, type: Boolean, default: false
      end
      get do
        filterrific = Filterrific::ParamSet.new(Product, search_query: params.search_query,
                                                sort_by: params.sorted_by,
                                                with_price_range: price_range(params.price_range),
                                                with_product_type: params.product_type,
                                                with_tags: params.tags,
                                                with_author: params.author_id,
                                                published_only: params.only_published,
                                                featured: params.featured)
        products = Product.includes(product_template: [:template_variants]).filterrific_find(filterrific).page(params.page).per(params.per_page)
        if products
          ProductListSerializer.new(products).as_json
        else
          error!({ errors: { base: ['no products matching given criteria'] } }, 404)
        end
      end

      desc 'return product by id'
      get ':id' do
        product = Product.where('id = ? AND (published = ? OR author_id = ?)', params.id, true, current_user).first!
        ProductSerializer.new(product).as_json
      end

      desc 'create product'
      params do
        optional :name, type: String
        optional :product_template_id, type: Integer
        optional :description, type: String
        optional :uploaded_image, type: String
        optional :image, type: File
        optional :preview, type: File
        optional :published, type: Boolean
        optional :tags, type: Array[String]
      end
      post do
        error!({ errors: { themes: ['Select at least one theme'] } }, 422) if themes_invalid(params)
        product = CreateProduct.new(params, current_user).call
        ProductSerializer.new(product).as_json
      end

      desc 'update product'
      params do
        requires :id, type: Integer
        requires :product, type: Hash do
          optional :published, type: Boolean
          optional :tags, type: Array[String]
          optional :name, type: String
        end
      end
      put ':id' do
        authenticate!
        product = UpdateProduct.new(params.id, params.product, current_user).call
				status(422) unless product.valid?
        ProductSerializer.new(product).as_json
      end

      desc 'remove product'
      params do
        optional :uuid, type: String
      end
      delete ':id' do
        if current_user
          product = Product.find_by!(id: params.id)
          error!({ errors: { base: ['unauthorized'] } }, 401) if product.author_id != current_user.id
        else
          product = Product.find_by!(id: params.id, uuid: params.uuid)
        end
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
          error!({ errors: { base: ['cannot publish not own product'] } }, 422)
        end
      end
    end
  end
end
