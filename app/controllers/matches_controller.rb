class MatchesController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_blocked
	before_action :authenticate_admin, only: [:destroy, :new]

	def new

	end

	def destroy
    @match = Match.find(params[:id])
		@group = @match.group
    @match.destroy
    
		respond_to do |format|
			format.turbo_stream do
				render turbo_stream: turbo_stream.remove("match_#{params[:id]}")
		end
		end
  end
end
  