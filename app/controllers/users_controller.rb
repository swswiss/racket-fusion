class UsersController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_blocked
	before_action :authenticate_admin, only: [:create_promotion, :create_points]
	before_action :authorize_user, only: [:show]

	def show
		@user = User.find(params[:id])
		lvl_user = @user.level
		users = User.where(level: @user.level).order(points: :desc)
		user = User.find(params[:id])  # Replace with the actual user you're interested in

		@user_rank = users.index(user) + 1

	end

	def expert
		if params[:username].present?
			@pagy, @users = pagy(User.where(level: "Expert").order(points: :desc).search_by_username(params[:username]),  items: 13)
		else
			@pagy, @users = pagy(User.where(level: "Expert").order(points: :desc),  items: 13)
		end
	end

	def beginner
		if params[:username].present?
			@pagy, @users = pagy(User.where(level: "Beginner").order(points: :desc).search_by_username(params[:username]),  items: 13)
		else
			@pagy, @users = pagy(User.where(level: "Beginner").order(points: :desc),  items: 13)
		end
	end

	def medium
		if params[:username].present?
			@pagy, @users = pagy(User.order(points: :desc).where(level: "Medium").search_by_username(params[:username]),  items: 13)
		else
			@pagy, @users = pagy(User.order(points: :desc).where(level: "Medium"),  items: 13)
		end
	end

	def medium_plus
		if params[:username].present?
			@pagy, @users = pagy(User.order(points: :desc).where(level: "Medium Plus").search_by_username(params[:username]),  items: 13)
		else
			@pagy, @users = pagy(User.order(points: :desc).where(level: "Medium Plus"),  items: 13)
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
		respond_to do |format|
			format.html { redirect_to dashboard_path }
			format.turbo_stream do
				render turbo_stream: turbo_stream.append('points') { 
					"<div class=\"alert alert-success alert-dismissible fade show\" role=\"alert\" style=\"position: fixed; top: 10px; right: 10px; width: 300px; display: inline-block;\">
					<strong style=\"font-size: 12px;\">Great!</strong> <font style=\"font-size: 12px;\">You have just created a Points for Players</font>
						<button type=\"button\" class=\"btn-close btn-sm\" data-bs-dismiss=\"alert\" aria-label=\"Close\"></button>
					</div>".html_safe
				}
			end
		end
	end

	

	def create_promotion
		user = User.find(params[:user_id])
		if params[:level].present?
			user.update(level: params[:level])
		end
		if params[:level] == "Beginner"
			r = "beginner"
		elsif params[:level] == "Medium"
			r = "medium"
		elsif params[:level] == "Medium Plus"
			r = "medium_plus"
		else
			r = "expert"
		end

		flash[:notice] = "#{user.username} is promoted to level #{params[:level]}"
    redirect_to send("#{r}_users_path")
	end

	private

  def authorize_user
    # Check if the current user is an admin or the same as the user being shown
		if (current_user.admin == true)
      return true
    end
    if !(current_user.id.to_s == params[:id])
      redirect_to root_path, alert: "You are not authorized to view this page."
    end
  end
end