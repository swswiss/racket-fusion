class RoundsController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_admin, only: [:destroy, :print_groups_medium]

	def print_groups_medium
		group = Group.find(params[:id])
		tournament = group.tournament
		@groups_medium = tournament.groups.where(level: "level_2")

		@groups_with_matches = {}
		@groups_medium.each do |group|
			matches = group.matches.where(kind: "group") # Assuming you have a `has_many :matches` association in your Group model
			@groups_with_matches[group] = matches
		end
		
		respond_to do |format|
      format.html
      format.pdf do
        render pdf: "file_name", template: 'tournaments/_groups_partial.html.erb'
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
  