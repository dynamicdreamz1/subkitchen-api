class CommentListSerializer
  def as_json(options={})
    data = {
        comments: serialized_comments,
        meta: {
            current_page: comments.current_page,
            total_pages: comments.total_pages
        }
    }

    data.as_json(options)
  end

  private

  attr_accessor :comments

  def initialize(comments)
    @comments = comments
  end

  def serialized_comments
    comments.map do |comment|
      single_comment = single_comment(comment)

      single_comment[:errors] = comment.errors if comment.errors.any?
      single_comment
    end
  end

  def single_comment(comment)
    {
        id: comment.id,
        product_id: comment.product_id,
        user_id: comment.user_id,
        content: comment.content,
        created_at: comment.created_at
    }
  end
end
