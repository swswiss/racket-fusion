class ApplicationController < ActionController::Base
  include Pagy::Backend
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :redirect_to_username_form, if: -> { user_signed_in? && current_user.username.blank? }

  protected

  def authenticate_admin
    if !current_user.admin?
      flash[:alert] = "You don't have permission to perform this action."
      redirect_to root_path
    end
  end

  def after_sign_in_path_for(resource)
    dashboard_path
  end

  def redirect_to_username_form
    redirect_to new_username_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:phone])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:level])
  end
end
