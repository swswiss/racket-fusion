class RegistrationsController < ApplicationController
	before_action :authenticate_user!

	def create
		
		if tournament.max_lvl1 <= tournament.registrations.where(level_registration: "level_1").count
			flash[:alert] = "You don't have permission to perform this action."
      redirect_to root_path and return
		end
		@registration = current_user.registrations.create(tournament: tournament)

		if params[:level_param].present?
			@registration.update(level_registration: params[:level_param])
		end

		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream
		end
	end

	def create_level_two
		if tournament.max_lvl2 <= tournament.registrations.where(level_registration: "level_2").count
			flash[:alert] = "You don't have permission to perform this action."
      redirect_to root_path and return
		end
		@registration = current_user.registrations.create(tournament: tournament)
		
		if params[:level_param].present?
			@registration.update(level_registration: params[:level_param])
		end

		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream
		end
	end

	def create_level_three
		if tournament.max_lvl3 <= tournament.registrations.where(level_registration: "level_3").count
			flash[:alert] = "You don't have permission to perform this action."
      redirect_to root_path
		end
		@registration = current_user.registrations.create(tournament: tournament)
		
		if params[:level_param].present?
			@registration.update(level_registration: params[:level_param])
		end

		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream
		end
	end

	def create_level_four
		if tournament.max_lvl4 <= tournament.registrations.where(level_registration: "level_4").count
			flash[:alert] = "You don't have permission to perform this action."
      redirect_to root_path
		end
		@registration = current_user.registrations.create(tournament: tournament)
		
		if params[:level_param].present?
			@registration.update(level_registration: params[:level_param])
		end

		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream
		end
	end

	def destroy
		if !tournament.registrations.find(params[:id]).present?
			debugger
		end
		@registration = tournament.registrations.find(params[:id])
		@registration.destroy

		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream
		end
	end

	def destroy_level_two
		if !tournament.registrations.find(params[:id]).present?
			debugger
		end
		@registration = tournament.registrations.find(params[:id])
		@registration.destroy

		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream
		end
	end

	def destroy_level_three
		if !tournament.registrations.find(params[:id]).present?
			debugger
		end
		@registration = tournament.registrations.find(params[:id])
		@registration.destroy

		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream
		end
	end

	def destroy_level_four
		if !tournament.registrations.find(params[:id]).present?
			debugger
		end
		@registration = tournament.registrations.find(params[:id])
		@registration.destroy

		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream
		end
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