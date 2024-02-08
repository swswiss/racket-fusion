class UsernamesController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_blocked
	before_action :authenticate_admin, only: [:index]
	skip_before_action :redirect_to_username_form

	def index
		if params[:username].present?
			@pagy, @users = pagy(User.search_by_username(params[:username]),  items: 13)
		else
			@pagy, @users = pagy(User.all,  items: 13)
		end
	end

	def update_status
    @user = User.find(params[:id])
		current_status = @user.status

		if current_status == 0 || current_status == nil
			new_status = 1
		else
			new_status = 0
		end
    if @user.update(status: new_status)
      # Assuming you have a `new_status` method defined somewhere, adjust this accordingly
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@user, partial: "user", locals: { user: @user }) }
      end
    else
      # Handle errors if any
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