class RoundsController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_admin, only: [:destroy, :print_rounds_medium]

	def print_rounds_medium
		round = Round.find(params[:id])
		tournament = round.tournament
		@rounds_medium = tournament.rounds.where(level: "level_2")

        @last_match = tournament.rounds.where(level: "level_2").order(created_at: :desc).first&.matches&.size
		if @last_match == 1 && tournament.rounds.where(level: "level_2").order(created_at: :desc).first.matches.first&.winner != nil
		    @winner = Registration.find(tournament.rounds.where(level: "level_2").order(created_at: :desc).first.matches.first&.winner).user.username
		end

		@rounds_with_matches = {}
		@rounds_medium.each do |round|
			matches = round.matches.where(kind: "bracket") # Assuming you have a `has_many :matches` association in your Group model
			@rounds_with_matches[round] = matches
		end

		respond_to do |format|
            format.html
            format.pdf do
              render pdf: "file_name", template: 'tournaments/_brackets_partial.html.erb'
            end
          end
    end


	def destroy
		@round = Round.find(params[:id])
		@round.destroy
		respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@round) }
      format.html { redirect_to groups_path, notice: 'Round was successfully destroyed.' }
    end
	end
end
  