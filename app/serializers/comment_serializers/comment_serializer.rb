class CommentSerializer
  def as_json(options={})
    data = {
        comment:
            {
                id: comment.id,
                product_id: comment.product_id,
                user_id: comment.user_id,
                content: comment.content,
                created_at: comment.created_at
            }
    }
    data[:errors] = comment.errors if comment.errors.any?

    data.as_json(options)
  end

  private

  attr_accessor :comment

  def initialize(comment)
    @comment = comment
  end
end
