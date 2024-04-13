class StatisticsController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_blocked
	require "pagy/extras/array"

	def index
		@pagy, @matches_for_current_user = pagy(Match.for_current_user(current_user), items: 13)
	end

	def duel
		@pagy, @matches_for_current_user = pagy(Match.for_current_user(current_user), items: 13)
		registration_ids = Registration.where(teammate_id: current_user.id).pluck(:id)
        @all_teammates = Match.where('first_player IN (?) OR second_player IN (?)', registration_ids, registration_ids) || []
	end

	def headtohead
		opponent = User.find(params[:user_id])
		@duels = Match.duels(current_user, opponent) rescue []
		registration_ids = Registration.where(teammate_id: opponent.id).pluck(:id)

        @all_teammates = Match.where('second_player IN (?)', registration_ids) || []
	
		render turbo_stream: 
			turbo_stream.replace("duels",
				partial: "statistics/duel_table",
				locals: {duels: @duels})
	end
end