class Post < ApplicationRecord

  belongs_to :created_by, foreign_key: "created_by_id", class_name: "User"
  has_many :post_comments, dependent: :destroy

  mount_uploader :image, ImageUploader

  validates :message, :presence => true

end
