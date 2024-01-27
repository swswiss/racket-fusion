class TournamentsController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_admin, only: [:create, :change_status_opened, :change_status_closed, :create_groups, :destroy]
	require "pagy/extras/array"
	require 'httparty'
	

	def index
		@pagy, @all_tournaments = pagy_array(Tournament.where(league: false).includes(:registrated_users, :user).order(created_at: :desc).map do |tournament| 
			TournamentPresenter.new(tournament: tournament, current_user: current_user)
		end,
		items: 5
		)
		city = 'Iasi'
		api_key = '8391a6cc0b0ad7ddc8ec7fedf25c5a39'

		response = HTTParty.get("https://api.openweathermap.org/data/2.5/weather?q=#{city}&appid=#{api_key}&units=metric")

		if response.code == 200
			weather_data = JSON.parse(response.body)
			@weather = weather_data['weather'].first["main"].downcase
		else
			@weather = "clear"
		end
  end

	def show
		@tournament = Tournament.find(params[:id])
		if @tournament.double == false
			@players_lvl_beginner = @tournament.registrations.where(level_registration: "level_1", waitlisted: false).pluck(:id, :user_id)
			@players_lvl_medium = @tournament.registrations.where(level_registration: "level_2", waitlisted: false).pluck(:id, :user_id)
			@players_lvl_mediumplus = @tournament.registrations.where(level_registration: "level_3", waitlisted: false).pluck(:id, :user_id)
			@players_lvl_expert = @tournament.registrations.where(level_registration: "level_4", waitlisted: false).pluck(:id, :user_id)
			@players_lvl_waitlisted = @tournament.registrations.where(waitlisted: true).pluck(:id, :user_id)
		else
			@players_lvl_beginner = @tournament.registrations.where(level_registration: "level_1", waitlisted: false, pending: "accepted").pluck(:id, :user_id)
			@players_lvl_medium = @tournament.registrations.where(level_registration: "level_2", waitlisted: false, pending: "accepted").pluck(:id, :user_id)
			@players_lvl_mediumplus = @tournament.registrations.where(level_registration: "level_3", waitlisted: false, pending: "accepted").pluck(:id, :user_id)
			@players_lvl_expert = @tournament.registrations.where(level_registration: "level_4", waitlisted: false, pending: "accepted").pluck(:id, :user_id)
			@players_lvl_waitlisted = @tournament.registrations.where(waitlisted: true, pending: "accepted").pluck(:id, :user_id)
		end
	end

	def update
		@tournament = Tournament.find(params[:id])
  	if @tournament.update(tournament_params)
			if params[:confirmation].present?
				@tournament.update(confirmation: params[:confirmation] == "1" ? true : false)
			end
			if params[:tournament][:league].present?
				@tournament.update(league: params[:tournament][:league] == "1" ? true : false)
			end
			if params[:tournament_status1].present?
				@tournament.update(status: params[:tournament_status1] == "opened" ? true : false)
			end
    	if params[:tournament][:league] == "1"
				respond_to do |format|
					format.html { redirect_to leagues_path }
				end
			else
				respond_to do |format|
					format.html { redirect_to tournaments_path }
				end
			end
  	else
    	# Handle errors, if any
    	render json: { errors: @tournament.errors.full_messages }, status: :unprocessable_entity
  	end
	end

	def create
		@tournament = Tournament.new(tournament_params.merge(user: current_user))
		if @tournament.save
			if params[:confirmation].present?
				@tournament.update(confirmation: params[:confirmation] == "1" ? true : false)
			end
			if params[:tournament][:double].present?
				@tournament.update(double: params[:tournament][:double] == "1" ? true : false)
			end
			if params[:tournament][:league].present?
				@tournament.update(league: params[:tournament][:league] == "1" ? true : false)
			end
			if params[:tournament_status].present?
				@tournament.update(status: params[:tournament_status] == "opened" ? true : false)
			end
			if params[:tournament][:league] == "1"
				respond_to do |format|
					format.html { redirect_to leagues_path }
				end
			else
				respond_to do |format|
					format.html { redirect_to tournaments_path }
				end
			end
		else
			@error_messages = @tournament.errors.full_messages
			flash[:alert] = "Validation failed: " + @error_messages.join(', ')
			redirect_to tournaments_path
		end
	end

	def change_status_opened
		@tournament = Tournament.find(params[:id])
		@tournament.update(status: true)
		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream
		end
	end

	def create_brackets
		debugger
		if params[:selected_players].length < 2
			respond_to do |format|
				format.html { redirect_to dashboard_path }
				format.turbo_stream do
					render turbo_stream: turbo_stream.prepend('altceva') { 
						"<div class=\"alert alert-danger alert-dismissible fade show\" role=\"alert\" style=\"position: fixed; top: 10px; right: 10px; width: 300px; display: inline-block;\">
						<strong style=\"font-size: 12px;\">Ooops!</strong> <font style=\"font-size: 12px;\">Something went worng!</font>
							<button type=\"button\" class=\"btn-close btn-sm\" data-bs-dismiss=\"alert\" aria-label=\"Close\"></button>
						</div>".html_safe
					}
				end
			end
			return nil
		end

		tournament = Tournament.find(params[:id])
    selected_player_ids = params[:selected_players] || []
		selected_player_ids = selected_player_ids.map(&:to_i)
		level_round = Registration.find(selected_player_ids.first).level_registration

		if level_round == "level_1"
			level = "Beginner"
		elsif level_round == "level_2"
			level = "Medium"
		elsif level_round == "level_3"
			level = "Medium Plus"
		else
			level = "Expert"
		end

		round = Round.create(level: level_round, tournament: tournament)
		if level_round == "level_1"
			level = "Beginner"
		elsif level_round == "level_2"
			level = "Medium"
		elsif level_round == "level_3"
			level = "Medium Plus"
		else
			level = "Expert"
		end

		generate_random_matches_for_brackets(selected_player_ids, round, tournament, level_round)

		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream do
				render turbo_stream: turbo_stream.append('altceva') { 
					"<div class=\"alert alert-success alert-dismissible fade show\" role=\"alert\" style=\"position: fixed; top: 10px; right: 10px; width: 300px; display: inline-block;\">
					<strong style=\"font-size: 12px;\">Great!</strong> <font style=\"font-size: 12px;\">You have just created a Bracket!</font>
						<button type=\"button\" class=\"btn-close btn-sm\" data-bs-dismiss=\"alert\" aria-label=\"Close\"></button>
					</div>".html_safe
				}
			end
		end
	end

	def generate_random_matches_for_brackets(players, round, tournament, level_round)
		return nil if players.length < 2

		debugger
		shuffled_players = players.shuffle
		paired_players = shuffled_players.each_slice(2).to_a

		paired_players.each do |pair|
			first_player_id = pair[0]
			second_player_id = pair[1]
			match = Match.create(
				first_player: first_player_id,
				second_player: second_player_id,
				round_id: round.id,
				group_id: Group.first.id,
				tournament: tournament,
				level: level_round,
				kind: "bracket"
			)
		end
	end

	def create_groups
		if params[:selected_players].length < 2
			respond_to do |format|
				format.html { redirect_to dashboard_path }
				format.turbo_stream do
					render turbo_stream: turbo_stream.prepend('altceva') { 
						"<div class=\"alert alert-danger alert-dismissible fade show\" role=\"alert\" style=\"position: fixed; top: 10px; right: 10px; width: 300px; display: inline-block;\">
						<strong style=\"font-size: 12px;\">Ooops!</strong> <font style=\"font-size: 12px;\">Something went worng!.</font>
							<button type=\"button\" class=\"btn-close btn-sm\" data-bs-dismiss=\"alert\" aria-label=\"Close\"></button>
						</div>".html_safe
					}
				end
			end
			return nil
		end

		tournament = Tournament.find(params[:id])
    selected_player_ids = params[:selected_players] || []
		selected_player_ids = selected_player_ids.map(&:to_i)
		level_group = Registration.find(selected_player_ids.first).level_registration
		group = Group.create(level: level_group, tournament: tournament)
		if level_group == "level_1"
			@level = "Beginner"
		elsif level_group == "level_2"
			@level = "Medium"
		elsif level_group == "level_3"
			@level = "Medium Plus"
		else
			@level = "Expert"
		end
		
		generate_random_matches(selected_player_ids, group, tournament, level_group)

		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream
		end
  end

	def generate_random_matches(players, group, tournament, level_group)
		return nil if players.length < 2
	
		shuffled_players = players.shuffle
		matches = shuffled_players.combination(2).to_a
	
		matches.each do |match|
			first_player_id = match[0]
			second_player_id = match[1]

			match = Match.create(first_player: first_player_id, second_player: second_player_id, 
													 group_id: group.id, tournament: tournament, level: level_group, kind: "group")
		end
	end

	def beginner_schedule
		@tournament = Tournament.find(params[:id])
		@groups_beginner = @tournament.groups.where(level: "level_1")

	end

	def medium_schedule
		@tournament = Tournament.find(params[:id])
		@groups_medium = @tournament.groups.where(level: "level_2")
		@rounds_medium = @tournament.rounds.where(level: "level_2")

		@last_match = @tournament.rounds.where(level: "level_2").order(created_at: :desc).first&.matches&.size
		if @last_match == 1 && @tournament.rounds.where(level: "level_2").order(created_at: :desc).first.matches.first&.winner != nil
			@winner = Registration.find(@tournament.rounds.where(level: "level_2").order(created_at: :desc).first.matches.first&.winner).user.username
		end

		@groups_with_matches = {}
		@groups_medium.each do |group|
			matches = group.matches.where(kind: "group") # Assuming you have a `has_many :matches` association in your Group model
			@groups_with_matches[group] = matches
		end

		@rounds_with_matches = {}
		@rounds_medium.each do |round|
			matches = round.matches.where(kind: "bracket") # Assuming you have a `has_many :matches` association in your Group model
			@rounds_with_matches[round] = matches
		end

		@data = {}

		@groups_medium.each do |group|
			@data[group.id] = {}

			group.matches.where(kind: "group").each do |match|
				winner_id = match.winner
				loser_id = match.first_player == match.winner ? match.second_player : match.first_player

				# Initialize data for winner if nil
				@data[group.id][winner_id] ||= {
					matches_played: 0,
					sets_won: 0,
					sets_lost: 0,
					matches_won: 0
				}
		
				# Initialize data for loser if nil
				@data[group.id][loser_id] ||= {
					matches_played: 0,
					sets_won: 0,
					sets_lost: 0,
					matches_won: 0
				}
		
				# Extract sets from the score string
				sets = match.score&.split(' ')

				# Count sets won and lost for both winner and loser
				sets&.each do |set|
					player_score, opponent_score = set.split('-').map(&:to_i)
					if @data[group.id][winner_id] && @data[group.id][loser_id]
						if player_score > opponent_score
							
								@data[group.id][match.first_player][:sets_won] += 1
								@data[group.id][match.second_player][:sets_lost] += 1
						
						else
					
								@data[group.id][match.second_player][:sets_won] += 1
								@data[group.id][match.first_player][:sets_lost] += 1
						
						end
					end
				end
		
				# Count matches won for the winner
				if @data[group.id][winner_id]
					@data[group.id][winner_id][:matches_won] += 1
					@data[group.id][winner_id][:matches_played] += 1 if match.score.present?
				end
				if @data[group.id][loser_id] && match.score.present?
					@data[group.id][loser_id][:matches_played] += 1
				end
			end
		end
		@data = @data.transform_values do |players_data|
			players_data.sort_by do |player_id, data|
				[-data[:matches_won], -data[:sets_won]]
			end.to_h
		end.to_h

	end

	def medium_plus_schedule
		@tournament = Tournament.find(params[:id])
	end

	def expert_schedule
		@tournament = Tournament.find(params[:id])
	end

	def change_status_closed
		@tournament = Tournament.find(params[:id])
		@tournament.update(status: false)

		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream
		end
	end

	def destroy
    @tournament = Tournament.find(params[:id])
    @tournament.destroy

    respond_to do |format|
      format.html { redirect_to dashboard_path }
      format.turbo_stream
    end
  end

	private

	def tournament_params
		params.require(:tournament).permit(:name, :description, :status, :max_lvl1, :max_lvl2, :max_lvl3, :max_lvl4, :confirmation, :start_datetime, :finish_datetime, :league, :double)
	end
end