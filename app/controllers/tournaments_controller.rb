class TournamentsController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_admin, only: [:create, :change_status_opened, :change_status_closed]
	require "pagy/extras/array"
	

	def index
		@pagy, @all_tournaments = pagy_array(Tournament.includes(:registrated_users, :user).order(created_at: :desc).map do |tournament| 
			TournamentPresenter.new(tournament: tournament, current_user: current_user)
		end,
		items: 5
		)
  end

	def show
		@tournament = Tournament.find(params[:id])
		@players_lvl_beginner = @tournament.registrations.where(level_registration: "level_1", waitlisted: false).pluck(:id, :user_id)
		@players_lvl_medium = @tournament.registrations.where(level_registration: "level_2", waitlisted: false).pluck(:id, :user_id)
		@players_lvl_mediumplus = @tournament.registrations.where(level_registration: "level_3", waitlisted: false).pluck(:id, :user_id)
		@players_lvl_expert = @tournament.registrations.where(level_registration: "level_4", waitlisted: false).pluck(:id, :user_id)
		@players_lvl_waitlisted = @tournament.registrations.where(waitlisted: true).pluck(:id, :user_id)


	end

	def create
		@tournament = Tournament.new(tournament_params.merge(user: current_user))

		if @tournament.save
			if params[:confirmation].present?
				@tournament.update(confirmation: params[:confirmation] == "1" ? true : false)
			end
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

	def destroy
    @tournament = Tournament.find(params[:id])
    @tournament.destroy

    respond_to do |format|
      format.html { redirect_to dashboard_path }
      format.turbo_stream
    end
  end

	private

	def tournament_params
		params.require(:tournament).permit(:name, :description, :status, :max_lvl1, :max_lvl2, :max_lvl3, :max_lvl4, :confirmation)
	end
end