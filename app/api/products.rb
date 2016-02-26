module Products
  class Api < Grape::API
    get 'promo' do
      %w(http://lorempixel.com/400/400/
      http://lorempixel.com/1920/800/)
    end
    get 'tshirts' do
      %w(http://lorempixel.com/300/300/)
    end
    params do
      requires :invoice, type: Integer
      requires :payment_status, type: String
      requires :transaction_id, type: Integer
    end
    post 'payment_notification' do
      payment = Payment.find_by(id: params.invoice)
      if params.status == 'Completed'
        payment.update_attributes(status: params.payment_status, transaction_id: params.transaction_id)
        payment.payable.update_arrtibutes(purchased_at: DateTime.now, state: 'inactive')
      end
    end

    params do
      requires :invoice, type: Integer
      requires :payment_status, type: String
      requires :transaction_id, type: Integer
    end
    post 'user_verify_notification' do
      payment = Payment.find_by(id: params.invoice)
      if params.status == 'Completed'
        payment.update_attributes(status: params.payment_status, transaction_id: params.transaction_id)
        artist = payment.payable
        artist.update_arrtibutes(status: 'verified')
      end
    end
    resources :products do
      desc 'return all products'
      get '' do
        page = params[:page].to_i != 0? params[:page] : 1
        per_page = params[:per_page].to_i != 0? params[:per_page] : 30
        products = Product.page(page).per(per_page)
        {
          products: products.map{|p| ProductSerializer.new(p).as_json},
          meta: {
            current_page: products.current_page,
            total_pages: products.total_pages
          }
        }
      end

      desc 'return product by id'
      get ':id' do
        {product: ProductSerializer.new(Product.find(params[:id])).as_json}
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
        authenticate!
        product = CreateProduct.new(current_user, params).call
        unless product.save
          status :unprocessable_entity
        end
        product
      end

      desc 'remove product'
      delete ':id' do
        authenticate!
        product = Product.find_by(id: params.id, user_id: current_user.id)
        if product
          DeleteResource.new(product).call
        else
          status :unprocessable_entity
        end
      end

      desc 'publish product'
      params do
        requires :product_id, type: Integer
      end
      post 'publish' do
        product = Product.find_by(id: params.product_id)
        if product
          product.published = true
          unless product.save
            status :unprocessable_entity
          end
          product
        else
          status :unprocessable_entity
        end
      end
    end
  end
end
