class BlogsController < ApplicationController
	before_action :authenticate_user!
	before_action :authenticate_blocked
	before_action :authenticate_admin, only: [:index, :show, :create, :destroy]

	def index
		@blogs = Blog.all
	end

	def index_for_visitors
		@blogs = Blog.all
	end

	def show
		@blog = Blog.find(params[:id])
	end
	def edit
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

	def update
    @blog = Blog.find(params[:id])
    if @blog.update(blog_params)
      redirect_to @blog, notice: 'Blog was successfully updated.'
    else
      render :edit
    end
  end
		
	

	private

	def blog_params
		params.require(:blog).permit(:body)
	end
end