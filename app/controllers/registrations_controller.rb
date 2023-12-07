class RegistrationsController < ApplicationController
	before_action :authenticate_user!

	def create
		@registration = current_user.registrations.create(tournament: tournament)

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

	private

	def tournament
		@tournament ||= Tournament.find(params[:tournament_id])
	end
end