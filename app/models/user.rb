class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  include PgSearch::Model

  validates :phone, presence: true, length: { minimum: 10, maximum: 15 }
  validates :level, presence: true
  validates :date_of_birth, presence: false

  pg_search_scope :search_by_username, against: [:username], using: { tsearch: { prefix: true } }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :tweets, dependent: :destroy
  has_one_attached :avatar
  has_many :likes, dependent: :destroy
  has_many :liked_tweets, through: :likes, source: :tweet

  has_many :registrations, dependent: :destroy
  has_many :registrated_tournaments, through: :registrations, source: :tournament

  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_tweets, through: :bookmarks, source: :tweet

  before_create :set_default_points

  validates :username, uniqueness: { case_sensitive: false }, allow_blank: true

  before_save :set_display_name ,if: -> { username.present? && display_name.blank? }

  def self.ransackable_attributes(auth_object = nil)
    ["username"]
  end
  def self.ransackable_associations(auth_object = nil)
    ["avatar_attachment", "avatar_blob", "bookmarked_tweets", "bookmarks", "liked_tweets", "likes", "pg_search_document", "registrated_tournaments", "registrations", "tweets"]
  end

  def set_display_name
    self.display_name = username.humanize
  end

  def calculate_age
    if date_of_birth.present?
      current_date = Date.current

      # Calculate age
      age = current_date.year - date_of_birth.year

      # Adjust age if the birthday hasn't occurred yet this year
      age -= 1 if current_date < date_of_birth + age.years

      age
    else
      "-"
    end
  end

  private

  def set_default_points
    self.points ||= 0
  end
end
