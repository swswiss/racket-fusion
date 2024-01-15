class BlogsController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_admin, only: :destroy

	def index
		@blogs = Blog.all
	end

	def create
		@blog = Blog.new(blog_params)

		if @blog.save
			respond_to do |format|
				format.html { redirect_to dashboard_path }
				format.turbo_stream
			end
		end
	end

	private

	def blog_params
		params.require(:blog).permit(:body)
	end
end