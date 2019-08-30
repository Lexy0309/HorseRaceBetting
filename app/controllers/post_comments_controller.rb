class PostCommentsController < ApplicationController

  before_action :access_deny_in_if_not_a_user
  before_action :set_post_comment, only: [:destroy]

  def index
    @posts = Post.all.order("created_at desc")
  end

  def create
    @post_comment = PostComment.new(post_comment_params)
    @post_comment.save
  end

  def destroy
    if @post_comment.user_id==current_user.id || current_user.is_admin?
      @post_comment.destroy
    end
  end

  private

  def set_post_comment
    @post_comment = PostComment.find(params[:id])
  end

  def post_comment_params
    params.require(:post_comment).permit(:post_id, :user_id, :comment, :image)
  end


end
