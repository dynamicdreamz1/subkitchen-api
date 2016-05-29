class CommentSerializer
  def as_json(options = {})
    data.as_json(options)
  end

  private

  attr_accessor :data

  def initialize(comment)
    @data = { comment: comment }
  end

  def comment
    {
      id: comment.id,
      product_id: comment.product_id,
      user_id: comment.user_id,
      content: comment.content,
      created_at: comment.created_at,
      errors: comment.errors
    }
  end
end
