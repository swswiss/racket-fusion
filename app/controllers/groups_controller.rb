class GroupsController < ApplicationController

	def destroy
		@group = Group.find(params[:id])
		@group.destroy
		redirect_to tournaments_path, notice: 'Group was successfully destroyed.'
	end
	
end
  