class LeaguesController < ApplicationController
	before_action :authenticate_user!

	require "pagy/extras/array"
	

	def index
		@pagy, @all_tournaments = pagy_array(Tournament.where(league: true).includes(:registrated_users, :user).order(created_at: :desc).map do |tournament| 
			TournamentPresenter.new(tournament: tournament, current_user: current_user)
		end,
		items: 5
		)
    end
end