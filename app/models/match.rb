class Match < ApplicationRecord
    belongs_to :group
    belongs_to :tournament

    scope :for_current_user, ->(user) {
        registration_ids = Registration.where(user_id: user.id).pluck(:id)
        where('first_player IN (?) OR second_player IN (?)', registration_ids, registration_ids)
    }
end
