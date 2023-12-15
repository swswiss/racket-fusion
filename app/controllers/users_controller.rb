class UsersController < ApplicationController
    def index
			if params[:username].present?
				@users = User.search_by_username(params[:username])
			else
				@users = User.all
			end
    end
		
		
  end