class Tournament < ApplicationRecord
  include ActionView::Helpers::DateHelper
	include Rails.application.routes.url_helpers
  include PgSearch::Model
  pg_search_scope :search_by_name, against: [:name], using: { tsearch: { prefix: true } }

  belongs_to :user
  has_many :registrations, dependent: :destroy
  has_many :registrated_users, through: :registrations, source: :user

  has_many :groups, dependent: :destroy
  has_many :matches, dependent: :destroy
  has_many :rounds, dependent: :destroy

  validates :max_lvl2, numericality: { only_integer: true }
  validates :max_lvl1, numericality: { only_integer: true }
  validates :max_lvl3, numericality: { only_integer: true }
  validates :max_lvl4, numericality: { only_integer: true }

  def created_at_time
		if (Time.zone.now - self.created_at) > 1.day
			self.created_at.strftime("%b %-d")
		else
			time_ago_in_words(self.created_at)
		end
	end
end