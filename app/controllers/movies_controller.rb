class MoviesController < ApplicationController
    def index
        search = params[:query].present? ? params[:query] : nil
        @movies = if search
            Movie.search(search)
        else
            Movie.all
        end
        
    end

    def show
    end


    private
    





end
