class GroupsController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_admin, only: [:destroy, :update_scores_group]


	def update_scores_group
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
  