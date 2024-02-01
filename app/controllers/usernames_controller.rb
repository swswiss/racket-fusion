class UsernamesController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_admin, only: [:index]
	skip_before_action :redirect_to_username_form

	def index
		if params[:username].present?
			@pagy, @users = pagy(User.search_by_username(params[:username]),  items: 13)
		else
			@pagy, @users = pagy(User.all,  items: 13)
		end
	end

	def new

  end

	def update
		if params[:avatar].present?
			current_user.update(image_profile: params[:avatar])
		end
		if username_params[:username].present? && current_user.update(username_params)
			flash[:notice] = "Username succesfully changed."
			redirect_to dashboard_path
		else
			flash[:alert] = if username_params[:username].blank?
												"Please set a username"
											else
												current_user.errors.full_messages.join(", ")
											end
			redirect_to new_username_path
		end
	end

	private

	def username_params
		params.require(:user).permit(:username, :display_name, :avatar, :phone, :email, :date_of_birth, :password, :password_confirmation)
	end
end