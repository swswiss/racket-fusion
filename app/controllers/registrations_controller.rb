class RegistrationsController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_admin, only: [:modify_waitlisted_users]

	def invite
		@teammate = User.find(params[:user_id])
		@team_name = current_user.username + " + "+ @teammate.username

		team_is_existed = (Registration.find_by(tournament: tournament, user_id: current_user.id) rescue false) || (Registration.find_by(tournament: tournament, user_id: @teammate.id) rescue false) || (Registration.find_by(tournament: tournament, teammate_id: @teammate.id) rescue false) || (Registration.find_by(tournament: tournament, teammate_id: current_user.id) rescue false)

		if team_is_existed.present?
			respond_to do |format|
				format.html { redirect_to dashboard_path }
				format.turbo_stream
			end
		else
			if params[:level] == "Beginner"
				lvl = "level_1"
			elsif params[:level] == "Medium"
				lvl = "level_2"
			elsif params[:level] == "Medium Plus"
				lvl = "level_3"
			else
				lvl = "level_4"
			end
			@registration_double = current_user.registrations.create(tournament: tournament)
			@registration_double.update(waitlisted: tournament.confirmation, double: true, teammate_id: @teammate.id, pending: "pending", name: @team_name, level_registration: lvl)
		end

		@registrations_current_user = current_user.registrations.where(double: true)
    @registrations_from_user= Registration.where(teammate_id: current_user.id, double: true)

		render turbo_stream: 
				turbo_stream.replace("invitations",
					partial: "registrations/teams_table",
					locals: {registrations_current_user: @registrations_current_user, registrations_from_user: @registrations_from_user })
	end

	def accept
		registration = Registration.find(params[:id])
		registration.update(pending: "accepted")
		@registrations_current_user = current_user.registrations.where(double: true)
    @registrations_from_user= Registration.where(teammate_id: current_user.id, double: true)

		render turbo_stream: 
				turbo_stream.replace("invitations",
					partial: "registrations/teams_table",
					locals: {registrations_current_user: @registrations_current_user, registrations_from_user: @registrations_from_user })
	end

	def decline
		registration = Registration.find(params[:id])
		registration.update(pending: "declined")
		@registrations_current_user = current_user.registrations.where(double: true)
    @registrations_from_user= Registration.where(teammate_id: current_user.id, double: true)

		render turbo_stream: 
				turbo_stream.replace("invitations",
					partial: "registrations/teams_table",
					locals: {registrations_current_user: @registrations_current_user, registrations_from_user: @registrations_from_user })
	end

	def create
		if tournament.status == true
			if current_user.level == "Beginner"
				@eligible = true
				@registration = current_user.registrations.create(tournament: tournament)
				@registration.update(waitlisted: tournament.confirmation)

				if params[:level_param].present?
					@registration.update(level_registration: params[:level_param])
				end

				respond_to do |format|
					format.html { redirect_to dashboard_path }
					format.turbo_stream
				end
			else
				@eligible = false
				tournament
				respond_to do |format|
					format.html { redirect_to dashboard_path }
					format.turbo_stream
				end
			end
		end
	end

	def create_level_two
		if tournament.status == true
			if current_user.level == "Beginner" || current_user.level == "Medium" || current_user.level == "Medium Plus"
				@eligible = true
				@registration = current_user.registrations.create(tournament: tournament)
				@registration.update(waitlisted: tournament.confirmation)

				if params[:level_param].present?
					@registration.update(level_registration: params[:level_param])
				end

				respond_to do |format|
					format.html { redirect_to dashboard_path }
					format.turbo_stream
				end
			else
				@eligible = false
				tournament
				respond_to do |format|
					format.html { redirect_to dashboard_path }
					format.turbo_stream
				end
			end
		end
	end

	def create_level_three
		if tournament.status == true
			if current_user.level == "Expert" || current_user.level == "Medium" || current_user.level == "Medium Plus"
				@eligible = true
				@registration = current_user.registrations.create(tournament: tournament)
				@registration.update(waitlisted: tournament.confirmation)
				
				if params[:level_param].present?
					@registration.update(level_registration: params[:level_param])
				end

				respond_to do |format|
					format.html { redirect_to dashboard_path }
					format.turbo_stream
				end
			else
				@eligible = false
				tournament
				respond_to do |format|
					format.html { redirect_to dashboard_path }
					format.turbo_stream
				end
			end
		end
	end

	def create_level_four
		if tournament.status == true
			if current_user.level == "Expert" || current_user.level == "Medium Plus"
				@eligible = true
				@registration = current_user.registrations.create(tournament: tournament)
				@registration.update(waitlisted: tournament.confirmation)
				
				if params[:level_param].present?
					@registration.update(level_registration: params[:level_param])
				end

				respond_to do |format|
					format.html { redirect_to dashboard_path }
					format.turbo_stream
				end
			else
				@eligible = false
				tournament
				respond_to do |format|
					format.html { redirect_to dashboard_path }
					format.turbo_stream
				end
			end
		end
	end

	def destroy
		if tournament.status == true
			@registration = tournament.registrations.find(params[:id])
			@registration.destroy

			respond_to do |format|
				format.html { redirect_to dashboard_path }
				format.turbo_stream
			end
		end
	end

	def destroy_level_two
		if tournament.status == true
			@registration = tournament.registrations.find(params[:id])
			@registration.destroy

			respond_to do |format|
				format.html { redirect_to dashboard_path }
				format.turbo_stream
			end
		end
	end

	def destroy_level_three
		if tournament.status == true
			@registration = tournament.registrations.find(params[:id])
			@registration.destroy

			respond_to do |format|
				format.html { redirect_to dashboard_path }
				format.turbo_stream
			end
		end
	end

	def destroy_level_four
		if tournament.status == true
			@registration = tournament.registrations.find(params[:id])
			@registration.destroy

			respond_to do |format|
				format.html { redirect_to dashboard_path }
				format.turbo_stream
			end
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