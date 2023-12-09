class TournamentsController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_admin, only: [:create, :change_status_opened, :change_status_closed]

	def index
		@all_tournaments = Tournament.includes(:registrated_users, :user).order(created_at: :desc).map do |tournament| 
			TournamentPresenter.new(tournament: tournament, current_user: current_user)
		end
  end

	def create
		@tournament = Tournament.new(tournament_params.merge(user: current_user))

		if @tournament.save
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

	def change_status_closed
		@tournament = Tournament.find(params[:id])
		@tournament.update(status: false)
		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream
		end
	end

	private

	def tournament_params
		params.require(:tournament).permit(:name, :description, :status, :max_lvl1, :max_lvl2, :max_lvl3, :max_lvl4)
	end
end