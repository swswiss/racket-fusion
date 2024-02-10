class BlogvisitorsController < ApplicationController


	def index
        @pagy, @blogs = pagy(Blog.all,  items: 5)
	end

    def show
		@blog = Blog.find(params[:id])
	end

end