class UsersController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_admin, only: [:create_promotion]
	def index
		if params[:username].present?
			@pagy, @users = pagy(User.order(points: :desc).search_by_username(params[:username]),  items: 13)
		else
			@pagy, @users = pagy(User.order(points: :desc).all,  items: 13)
		end
	end

	def create_points
		points_params = params.require(:points).permit!
    points = points_params.transform_values { |value| value.present? ? value.to_i : nil }

    points.each do |user_id, user_points|
      user = User.find(user_id)
      next unless user # Skip if user not found

      user.points += user_points || 0
      user.save
    end
	end

	def create_promotion
		user = User.find(params[:user_id])
		if params[:level].present?
			user.update(level: params[:level])
		end
		flash[:notice] = "#{user.username} is promoted to level #{params[:level]}"
    redirect_to users_path
	end
end