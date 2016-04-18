module WishList
  class Api < Grape::API
    resources :wish_list do

      before do
        authenticate!
      end

      desc 'add product to wish list'
      params do
        requires :product_id, type: Integer
      end
      post do
        product = Product.find_by!(id: params.product_id, published: true)
        AddWishedProduct.new(current_user, product).call
      end

      desc 'remove product from wish list'
      params do
        requires :product_id, type: Integer
      end
      delete do
        product = Product.find(params.product_id)
        RemoveWishedProduct.new(current_user, product).call
      end

      desc 'get wish list'
      params do
        optional :page, type: Integer, default: 1
        optional :per_page, type: Integer, default: 20
      end
      get do
        products = current_user.wished_products.page(params.page).per(params.per_page)
        ProductListSerializer.new(products).as_json
      end
    end
  end
end
