class PostComment < ApplicationRecord

  belongs_to :post
  belongs_to :user

  mount_uploader :image, ImageUploader

  validates :comment, :presence => true

end
