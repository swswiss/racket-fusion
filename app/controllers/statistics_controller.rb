class StatisticsController < ApplicationController
	before_action :authenticate_user!
	require "pagy/extras/array"

	def index
		@pagy, @matches_for_current_user = pagy(Match.for_current_user(current_user), items: 13)
	end
end