class GroupsController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_blocked
	before_action :authenticate_admin, only: [:destroy, :update_scores_group, :print_groups_medium, :csv_groups_medium]


	def update_scores_group
		debugger
		if params[:rounds_submit] != nil
			tournament_id = Round.find(params[:id]).tournament.id
			level_round = Round.find(params[:id]).level
			@tournament = Tournament.find(tournament_id)
			@rounds_medium = @tournament.rounds.where(level: level_round)
			@rounds_with_matches = {}
			@rounds_medium.each do |round|
				matches = round.matches.where(kind: "bracket").order(created_at: :asc) # Assuming you have a `has_many :matches` association in your Group model
				@rounds_with_matches[round] = matches
			end
		end
		pattern = /\A(\d-\d\s){1,2}\d-\d\z/
  
		params[:match_scores].each do |_, score|
			if !!(score =~ pattern) == false && score.present?
				respond_to do |format|
					format.html { redirect_to dashboard_path }
					format.turbo_stream do
						render turbo_stream: turbo_stream.prepend('interesant') { 
							"<div class=\"alert alert-danger alert-dismissible fade show\" role=\"alert\" style=\"position: fixed; top: 10px; right: 10px; width: 300px; display: inline-block;\">
							<strong style=\"font-size: 12px;\">Ooops!</strong> <font style=\"font-size: 12px;\">There is an invalid score!</font>
								<button type=\"button\" class=\"btn-close btn-sm\" data-bs-dismiss=\"alert\" aria-label=\"Close\"></button>
							</div>".html_safe
						}
					end
				end
				return nil
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

	def csv_groups_medium
    require 'axlsx'
    respond_to do |format|
      format.xlsx do
        p = Axlsx::Package.new
        p.workbook.add_worksheet(name: 'Sheet1') do |sheet|
          # Add data to the spreadsheet
          sheet.add_row ['Name', 'Age', 'Occupation']
          sheet.add_row ['John Doe', 30, 'Developer']
          sheet.add_row ['Jane Doe', 25, 'Designer']
        end

        # Send the workbook as a response
        send_data p.to_stream.read, type: "application/xlsx", filename: 'example1.xlsx'
      end
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
					matches_won: 0,
					games_won: 0
				}
		
				# Initialize data for loser if nil
				@data[group.id][loser_id] ||= {
					matches_played: 0,
					sets_won: 0,
					sets_lost: 0,
					matches_won: 0,
					games_won: 0
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
								@data[group.id][match.first_player][:games_won] += player_score
								@data[group.id][match.second_player][:games_won] += opponent_score
						
						else
					
								@data[group.id][match.second_player][:sets_won] += 1
								@data[group.id][match.first_player][:sets_lost] += 1
								@data[group.id][match.first_player][:games_won] += player_score
								@data[group.id][match.second_player][:games_won] += opponent_score
						
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

	def add_match_to_group
		if params[:group_id].present? && params[:first_player].present? && params[:second_player].present?
			group = Group.find(params[:group_id])
			tournament = group.tournament
			registrations_first = tournament.registrations.where(user_id: params[:first_player]).first.id
			registrations_second = tournament.registrations.where(user_id: params[:second_player]).first.id
		else
			respond_to do |format|
				format.html { redirect_to dashboard_path }
				format.turbo_stream do
					render turbo_stream: turbo_stream.prepend('interesant') { 
						"<div class=\"alert alert-danger alert-dismissible fade show\" role=\"alert\" style=\"position: fixed; top: 10px; right: 10px; width: 300px; display: inline-block;\">
						<strong style=\"font-size: 12px;\">Ooops!</strong> <font style=\"font-size: 12px;\">Something went worng!</font>
							<button type=\"button\" class=\"btn-close btn-sm\" data-bs-dismiss=\"alert\" aria-label=\"Close\"></button>
						</div>".html_safe
					}
				end
			end
			return nil
		end
		if registrations_first.present? && registrations_second.present? && tournament.present?
			match = Match.create(first_player: registrations_first, second_player: registrations_second, 
														group_id: group.id, tournament: tournament, level: group.level, kind: "group")
			@groups_medium = tournament.groups.where(level: "level_2")

			@groups_with_matches = {}
			@groups_medium.each do |group|
				matches = group.matches.where(kind: "group") # Assuming you have a `has_many :matches` association in your Group model
				@groups_with_matches[group] = matches
			end
			@tournament = tournament
			render turbo_stream: 
				turbo_stream.replace("groupsss",
					partial: "tournaments/groups_partial",
					locals: { groups_with_matches: @groups_with_matches, tournament: @tournament})
		else
			respond_to do |format|
				format.html { redirect_to dashboard_path }
				format.turbo_stream do
					render turbo_stream: turbo_stream.prepend('interesant') { 
						"<div class=\"alert alert-danger alert-dismissible fade show\" role=\"alert\" style=\"position: fixed; top: 10px; right: 10px; width: 300px; display: inline-block;\">
						<strong style=\"font-size: 12px;\">Ooops!</strong> <font style=\"font-size: 12px;\">Something went worng!</font>
							<button type=\"button\" class=\"btn-close btn-sm\" data-bs-dismiss=\"alert\" aria-label=\"Close\"></button>
						</div>".html_safe
					}
				end
			end
			return nil
		end
		
	end
end
  