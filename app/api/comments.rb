module Comments
  class Api < Grape::API
    resources :comments do
      desc 'add comment'
      params do
        requires :comment, type: Hash do
          requires :product_id, type: Integer
          requires :content, type: String
        end
      end
      post do
        authenticate!
        product = Product.find(params.comment.product_id)
        comment = product.comments.create(user_id: current_user.try(:id), content: params.comment.content)
        CommentSerializer.new(comment).as_json
      end

      desc 'list all product comments'
      params do
        requires :product_id, type: Integer
        optional :page, type: Integer, default: 1
        optional :per_page, type: Integer, default: 20
      end
      get do
        product = Product.find(params.product_id)
        comments = Comment.product(product.id).order('created_at DESC').page(params.page).per(params.per_page)
        CommentListSerializer.new(comments).as_json
      end

      desc 'show comment'
      get ':id' do
        CommentSerializer.new(Comment.find(params.id)).as_json
      end
    end
  end
end
