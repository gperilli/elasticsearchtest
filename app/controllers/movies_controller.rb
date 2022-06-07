class MoviesController < ApplicationController
    def index
        #@movies = Movie.all
        #raise
        search = params[:query].present? ? params[:query] : nil
        @movies = if search
            Movie.search(search)
            #@movies = Movie.search("apples")
        else
            Movie.all
        end
        
    end

    def show
    end


    private
    





end
