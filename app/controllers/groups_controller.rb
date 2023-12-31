class GroupsController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_admin, only: [:destroy, :update_scores_group, :print_groups_medium]


	def update_scores_group
		if params[:rounds_submit] != nil
			tournament_id = Round.find(params[:id]).tournament.id
			level_round = Round.find(params[:id]).level
			@tournament = Tournament.find(tournament_id)
			@rounds_medium = @tournament.rounds.where(level: level_round)
			@rounds_with_matches = {}
			@rounds_medium.each do |round|
				matches = round.matches.where(kind: "bracket") # Assuming you have a `has_many :matches` association in your Group model
				@rounds_with_matches[round] = matches
			end
		end

		params[:match_scores].each do |match_id, score|
			match = Match.find(match_id)
			first_player = match.first_player
			second_player = match.second_player
			match.update(score: score)

			if score.present?
				if determine_winner(score, first_player, second_player) == true
					match.update(winner: first_player)
				else
					match.update(winner: second_player)
				end
			else
				match.update(winner: nil)
			end
		end

		params[:match_dates].each do |match_id, date_time|
			match = Match.find(match_id)
			match.update(date: date_time)
		end
		if params[:rounds_submit] != nil
			render turbo_stream: 
				turbo_stream.replace("omg",
					partial: "tournaments/brackets_partial",
					locals: {rounds_with_matches: @rounds_with_matches})
		end
		
	end

	def print_groups_medium
		group = Group.find(params[:id])
		@tournament = group.tournament
		@groups_medium = @tournament.groups.where(level: "level_2")

		@groups_with_matches = {}
		@groups_medium.each do |group|
			matches = group.matches.where(kind: "group") # Assuming you have a `has_many :matches` association in your Group model
			@groups_with_matches[group] = matches
		end
		####
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

		####
		
		respond_to do |format|
      format.html
      format.pdf do
        render pdf: "file_name", template: 'tournaments/_groups_partial.html.erb'
      end
    end
	end

	def determine_winner(score, first_player, second_player)
		sets = score.split(' ') # Split the score into sets
		first_player_sets = 0
		second_player_sets = 0
	
		sets.each do |set|
			games = set.split('-') # Split each set into games
			first_player_games = games[0].to_i
			second_player_games = games[1].to_i
	
			if first_player_games > second_player_games
				first_player_sets += 1
			else
				second_player_sets += 1
			end
		end
	
		if first_player_sets > second_player_sets
			return true
		elsif second_player_sets > first_player_sets
			return false
		end
	end

	def destroy
		@group = Group.find(params[:id])
		@group.destroy
		respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@group) }
      format.html { redirect_to groups_path, notice: 'Group was successfully destroyed.' }
    end
	end
end
  