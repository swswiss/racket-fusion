class RegistrationsController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_admin, only: [:modify_waitlisted_users]

	def create
		@registration = current_user.registrations.create(tournament: tournament)
		@registration.update(waitlisted: tournament.confirmation)

		if params[:level_param].present?
			@registration.update(level_registration: params[:level_param])
		end

		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream
		end
	end

	def create_level_two
		@registration = current_user.registrations.create(tournament: tournament)
		@registration.update(waitlisted: tournament.confirmation)

		if params[:level_param].present?
			@registration.update(level_registration: params[:level_param])
		end

		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream
		end
	end

	def create_level_three
		@registration = current_user.registrations.create(tournament: tournament)
		@registration.update(waitlisted: tournament.confirmation)
		
		if params[:level_param].present?
			@registration.update(level_registration: params[:level_param])
		end

		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream
		end
	end

	def create_level_four
		@registration = current_user.registrations.create(tournament: tournament)
		@registration.update(waitlisted: tournament.confirmation)
		
		if params[:level_param].present?
			@registration.update(level_registration: params[:level_param])
		end

		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream
		end
	end

	def destroy
		@registration = tournament.registrations.find(params[:id])
		@registration.destroy

		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream
		end
	end

	def destroy_level_two
		@registration = tournament.registrations.find(params[:id])
		@registration.destroy

		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream
		end
	end

	def destroy_level_three
		@registration = tournament.registrations.find(params[:id])
		@registration.destroy

		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream
		end
	end

	def destroy_level_four
		@registration = tournament.registrations.find(params[:id])
		@registration.destroy

		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream
		end
	end

	def modify_waitlisted_users
		@registration = Registration.find(params[:id])
		@tournament = Tournament.find(params[:tournament_id])
		@user = User.find(@registration.user_id)
		@registration.toggle!(:waitlisted)
		@action = "WaitListed"
		
		@players_lvl_beginner = @tournament.registrations.where(level_registration: "level_1", waitlisted: false).pluck(:id, :user_id)
		@players_lvl_medium = @tournament.registrations.where(level_registration: "level_2", waitlisted: false).pluck(:id, :user_id)
		@players_lvl_mediumplus = @tournament.registrations.where(level_registration: "level_3", waitlisted: false).pluck(:id, :user_id)
		@players_lvl_expert = @tournament.registrations.where(level_registration: "level_4", waitlisted: false).pluck(:id, :user_id)
		@players_lvl_waitlisted = @tournament.registrations.where(waitlisted: true).pluck(:id, :user_id)

		if @registration.waitlisted == false
			@action = @registration.level_registration
		end
		if @action == "level_1"
			@action = "Beginner"
		elsif @action == "level_2"
			@action = "Medium"
		elsif @action == "level_3"
			@action = "Medium Plus"
		elsif @action == "level_4"
			@action = "Expert"
		end

		render turbo_stream: 
			turbo_stream.replace("ceva",
				partial: "tournaments/player_info",
				locals: {user: @user, registration: @registration})
		
	end

	private

	def tournament
		if params[:tournament_id].present?
			@tournament ||= Tournament.find(params[:tournament_id])
		else
			@tournament ||= Tournament.find(params[:id])
		end
	end
end