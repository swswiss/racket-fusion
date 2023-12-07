class Registration < ApplicationRecord
  belongs_to :tournament, counter_cache: :registrations_count
  belongs_to :user

  validates :user_id, uniqueness: {scope: :tournament_id}
end
