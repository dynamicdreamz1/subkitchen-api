module Likes
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

      desc 'like product'
      post ':id/likes' do
        authenticate!
        product = Product.find_by(id: params.id)
        if product
          if !author?(current_user, product)
            valid = LikeProduct.new(product, current_user).call
            if valid
              { likes: product.likes.count }
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
      delete ':id/likes' do
        authenticate!
        product = Product.find_by(id: params.id)
        if product
          valid = UnlikeProduct.new(product, current_user).call
          if valid
            { likes: product.likes.count }
          else
            error!({errors: {base: ['no like with given user id']}}, 422)
          end
        else
          error!({errors: {base: ['no product with given id']}}, 422)
        end
      end
    end
  end
end
