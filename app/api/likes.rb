module Likes
  class Api < Grape::API
    resources :products do
      helpers do
        def author?(current_user, product)
          current_user.try(:id) == product.author_id
        end

        def like?(current_user, product, uuid)
          like = nil
          like = Like.where(likeable: product, user: current_user).exists? if current_user
          like ||= Like.where(likeable: product, uuid: uuid).exists?
        end
      end

      desc 'toggle like product'
      params do
        optional :uuid, type: String
      end
      post ':id/toggle_like' do
        product = Product.find(params.id)
        if !author?(current_user, product)
          proceeder = like?(current_user, product, params.uuid) ? UnlikeProduct : LikeProduct
          like = proceeder.new(product, current_user, params.uuid).call
          if like
            { likes_count: product.reload.likes_count, uuid: like.uuid }
          else
            error!({ errors: { base: ['please try again later'] } }, 422)
          end
        else
          error!({ errors: { base: ['cannot like own product'] } }, 422)
        end
      end
    end
  end
end
