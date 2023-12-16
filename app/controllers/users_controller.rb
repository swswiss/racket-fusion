class UsersController < ApplicationController
	before_action :authenticate_user!
	def index
		if params[:username].present?
			@pagy, @users = pagy(User.order(points: :desc).search_by_username(params[:username]),  items: 13)
		else
			@pagy, @users = pagy(User.order(points: :desc).all,  items: 13)
		end
	end
end