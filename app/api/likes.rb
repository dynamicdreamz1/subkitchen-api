module Likes
  class Api < Grape::API

    resources :products do

      helpers do
        def author?(current_user, product)
          current_user.id == product.author_id
        end
      end

      desc 'toggle like product'
      post ':id/toggle_like' do
        authenticate!
        product = Product.find(params.id)
        if !author?(current_user, product)
          proceeder = Like.where(likeable: product, user: current_user).exists? ?  UnlikeProduct : LikeProduct
          valid = proceeder.new(product, current_user).call
          if valid
            { likes_count: product.reload.likes_count }
          else
            error!({errors: {base: ['please try again later']}}, 422)
          end
        else
          error!({errors: {base: ['cannot like own product']}}, 422)
        end
      end
    end
  end
end
