class Tweet < ApplicationRecord
  belongs_to :user

  validates :body, presence: true, length: { maximum: 280 }

  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user
end
