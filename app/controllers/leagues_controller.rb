class LeaguesController < ApplicationController
	before_action :authenticate_user!
    before_action :authenticate_blocked

	require "pagy/extras/array"
    require 'httparty'
	

	def index
		@pagy, @all_tournaments = pagy_array(Tournament.where(league: true).includes(:registrated_users, :user).order(created_at: :desc).map do |tournament| 
			TournamentPresenter.new(tournament: tournament, current_user: current_user)
		end,
		items: 5
		)
        # city = 'Iasi'
		# api_key = '8391a6cc0b0ad7ddc8ec7fedf25c5a39'

		# response = HTTParty.get("https://api.openweathermap.org/data/2.5/weather?q=#{city}&appid=#{api_key}&units=metric")

		# if response.code == 200
		# 	weather_data = JSON.parse(response.body)
		# 	@weather = weather_data['weather'].first["main"].downcase
		# else
		# 	@weather = "clear"
		# end
    end
end