class GroupsController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_admin, only: [:destroy, :update_scores_group]


	def update_scores_group
	
		params[:match_scores].each do |match_id, score|
			match = Match.find(match_id)
			match.update(score: score)
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
  