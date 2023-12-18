class MatchesController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_admin, only: [:update]


	def update
		debugger
		@group = Group.find(params[:id])
		@group.destroy
		respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@group) }
      format.html { redirect_to groups_path, notice: 'Group was successfully destroyed.' }
    end
	end
end
  