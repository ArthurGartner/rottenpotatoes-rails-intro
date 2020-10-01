class MoviesController < ApplicationController

def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
      
    params_found = params[:ratings] || session[:storedparam]
      
    sort = params[:sort] || session[:storedsort]
      
    
    if !params[:sort] & session[:storedsort]
        if params_found
            redirect_to movies_path(:sort => sort, :ratings => params_found) and return
        else
            redirect_to movies_path(:sort => sort) and return
        end
    end
      
    if !params[:ratings] & session[:storedparam]
        if sort
            redirect_to movies_path(:sort => sort, :ratings => params_found) and return
        else
            redirect_to movies_path(:ratings => params_found) and return
        end
    end
            
      
    #3 possible redirects
      #-just sort
      #-just ratings
      #both ratings and sort
             
      
    @all_ratings = Movie.all_ratings
                  
    @selected_ratings = params_found || Movie.all_ratings_as_hash
      
        
    if !params_found.nil?
        session[:storedparam] = params_found
    end
        
    if !sort.nil?
        session[:storedsort] = sort
    end
      
    if sort == 'by_title'
        @movies = Movie.with_ratings(@selected_ratings.keys).order(:title)
        @title_class = 'bg-warning hilite'
    elsif sort == 'by_date'
        @date_class = 'bg-warning hilite'
        @movies = Movie.with_ratings(@selected_ratings.keys).order(:release_date)
    else 
        @movies = Movie.with_ratings(@selected_ratings.keys)
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
