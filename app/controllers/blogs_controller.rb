class BlogsController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_admin, only: [:create, :destroy]

	def index
		@blogs = Blog.all
	end

	def show
		@blog = Blog.find(params[:id])
		
	end

	def create
		@blog = Blog.new(blog_params)
	
		if @blog.save
			# Successful save
			redirect_to @blog, notice: 'Blog was successfully created.' # Redirect to the show page for the newly created blog
		else

		end
	end
	
	def destroy
		@blog = Blog.find(params[:id])
		@blog.destroy
	
		redirect_to blogs_path, notice: 'Blog was successfully destroyed.'
	end
		
	

	private

	def blog_params
		params.require(:blog).permit(:body)
	end
end