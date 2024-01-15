class BlogsController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_admin, only: [:create, :destroy]

	def index
		@blogs = Blog.all
	end

	def create
		@blog = Blog.new(blog_params)

		if @blog.save
			
					render turbo_stream: 
					turbo_stream.replace("blog_here",
						partial: "blogs/blog",
						locals: {blogs: Blog.all})
				end
			end
		
	

	private

	def blog_params
		params.require(:blog).permit(:body)
	end
end