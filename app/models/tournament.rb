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
end