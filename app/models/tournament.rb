class Tournament < ApplicationRecord
  include ActionView::Helpers::DateHelper
	include Rails.application.routes.url_helpers

  belongs_to :user
  has_many :registrations, dependent: :destroy
  has_many :registrated_users, through: :registrations, source: :user

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