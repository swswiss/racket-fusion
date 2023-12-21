class TournamentsController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_admin, only: [:create, :change_status_opened, :change_status_closed, :create_groups, :destroy]
	require "pagy/extras/array"
	

	def index
		@pagy, @all_tournaments = pagy_array(Tournament.includes(:registrated_users, :user).order(created_at: :desc).map do |tournament| 
			TournamentPresenter.new(tournament: tournament, current_user: current_user)
		end,
		items: 5
		)
  end

	def show
		@tournament = Tournament.find(params[:id])
		@players_lvl_beginner = @tournament.registrations.where(level_registration: "level_1", waitlisted: false).pluck(:id, :user_id)
		@players_lvl_medium = @tournament.registrations.where(level_registration: "level_2", waitlisted: false).pluck(:id, :user_id)
		@players_lvl_mediumplus = @tournament.registrations.where(level_registration: "level_3", waitlisted: false).pluck(:id, :user_id)
		@players_lvl_expert = @tournament.registrations.where(level_registration: "level_4", waitlisted: false).pluck(:id, :user_id)
		@players_lvl_waitlisted = @tournament.registrations.where(waitlisted: true).pluck(:id, :user_id)
	end

	def update
		@tournament = Tournament.find(params[:id])
  	if @tournament.update(tournament_params)
			if params[:confirmation].present?
				@tournament.update(confirmation: params[:confirmation] == "1" ? true : false)
			end
			if params[:tournament_status1].present?
				@tournament.update(status: params[:tournament_status1] == "opened" ? true : false)
			end
    	respond_to do |format|
				format.html { redirect_to tournaments_path }
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
			if params[:tournament_status].present?
				@tournament.update(status: params[:tournament_status] == "opened" ? true : false)
			end
			respond_to do |format|
				format.html { redirect_to tournaments_path }
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

	def create_groups
		tournament = Tournament.find(params[:id])
    selected_player_ids = params[:selected_players] || []
		selected_player_ids = selected_player_ids.map(&:to_i)
		level_group = Registration.find(selected_player_ids.first).level_registration
		group = Group.create(level: level_group, tournament: tournament)
		if level_group == "level_1"
			level = "Beginner"
		elsif level_group == "level_2"
			level = "Medium"
		elsif level_group == "level_3"
			level = "Medium Plus"
		else
			level = "Expert"
		end
		
		generate_random_matches(selected_player_ids, group, tournament, level_group)

		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream do
				render turbo_stream: turbo_stream.replace('altceva') { 
					"<div class=\"alert alert-success alert-dismissible fade show\" role=\"alert\">
						<strong>Great!</strong> You have just created a group for #{level}.
						<button type=\"button\" class=\"btn-close\" data-bs-dismiss=\"alert\" aria-label=\"Close\"></button>
					</div>".html_safe
				}
			end
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
													 group_id: group.id, tournament: tournament, level: level_group)
		end
	end

	def beginner_schedule
		@tournament = Tournament.find(params[:id])
		@groups_beginner = @tournament.groups.where(level: "level_1")

	end

	def medium_schedule
		@tournament = Tournament.find(params[:id])
		@groups_medium = @tournament.groups.where(level: "level_2")

		@groups_with_matches = {}
		@groups_medium.each do |group|
			matches = group.matches # Assuming you have a `has_many :matches` association in your Group model
			@groups_with_matches[group] = matches
		end

		@ids_with_most_winners = {}
		@groups_medium.each do |group|
			winners = group.matches.pluck(:winner).compact
			#if winners.uniq.length == winners.length
				# all_matches = group.matches
				# all_matches.each do |m|
				# 	score = m.score
				# 	sets = score.split(' ')
				# 	sets.each do |s|
				# 		games = s.split('-') 
				# 		first_player_games = games[0].to_i
				# 		second_player_games = games[1].to_i
						
				# 		if first_player_games > second_player_games
				# 			first_player_sets += 1
				# 		else
				# 			second_player_sets += 1
				# 		end
				# 	end
				# 	if first_player_sets > second_player_sets
				# 		return true
				# 	elsif second_player_sets > first_player_sets
				# 		return false
				# 	end
				# end
  		most_frequent_winner = winners.max_by { |winner| winners.count(winner) }
  		@ids_with_most_winners[group.id] = most_frequent_winner
		end
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
		params.require(:tournament).permit(:name, :description, :status, :max_lvl1, :max_lvl2, :max_lvl3, :max_lvl4, :confirmation)
	end
end