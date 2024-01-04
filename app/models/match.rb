class Match < ApplicationRecord
    belongs_to :group
    belongs_to :round
    belongs_to :tournament

    scope :for_current_user, ->(user) {
        registration_ids = Registration.where(user_id: user.id).pluck(:id)
        where('first_player IN (?) OR second_player IN (?)', registration_ids, registration_ids)
    }

    scope :duels, ->(user, opponent) {
  registration_ids_current_user = Registration.where(user_id: user.id).pluck(:id)
  registration_ids_opponent = Registration.where(user_id: opponent.id).pluck(:id)
  
  where(
    '(first_player IN (?) AND second_player IN (?)) OR (first_player IN (?) AND second_player IN (?))',
    registration_ids_current_user, registration_ids_opponent, registration_ids_opponent, registration_ids_current_user
  )
}

end
