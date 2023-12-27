class Round < ApplicationRecord
    belongs_to :tournament
    has_many :matches, dependent: :destroy
end
