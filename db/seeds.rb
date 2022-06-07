# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

def get_movie_hash(new_movie_index)
    url = "https://api.themoviedb.org/3/movie/#{new_movie_index}?api_key=a7cc25d497366000cfcd64f2c419f406"
    print "#{new_movie_index} #{url}" + "\r"
    $stdout.flush
    movie_hash_and_src = [JSON.parse(URI.open(url).read), url]
  end
  
  def horror_movie_query?(genres)
    # Detecting all horror movies among multiple genres
    horror_movie = false
    genres.each do |genre|
      horror_movie = true if genre["name"] == "Horror"
    end
    return horror_movie
  end
  
  def get_horror_movie_hash(new_movie_index)
    begin
      movie_hash_and_src = get_movie_hash(new_movie_index)
      movie_hash = movie_hash_and_src[0]
      src = movie_hash_and_src[1]
      horror_movie = horror_movie_query?(movie_hash["genres"])
      #puts ""
      #puts "movie_hash_title: #{movie_hash["title"]}"
      #puts ""
      if movie_hash["title"].present? == false
        puts "BANG - no title"
        # Handling empty hash
        puts "empty hash: #{src}"
        new_movie_index += 1
        get_horror_movie_hash(new_movie_index)
      #elsif horror_movie != true 
        # Not a  horror movie
        #new_movie_index += 1
       #get_horror_movie_hash(new_movie_index)
      else
        horror_movie_hash_and_index = [movie_hash, new_movie_index]
      end
    rescue OpenURI::HTTPError => ex
      # Handling missing hash
      new_movie_index += 1
      get_horror_movie_hash(new_movie_index)
    end
  end
  
  def get_unique_horror_movies(new_movie_index, movie_titles_array, movie_hash_array)
    horror_movie_hash_and_index = get_horror_movie_hash(new_movie_index)
    horror_movie_hash = horror_movie_hash_and_index[0]
    new_movie_index = horror_movie_hash_and_index[1]
    #puts "bang"
    #puts "movie hash array length: #{movie_hash_array.length}"
    #puts "bang"
    #puts "movie hash array last item: #{movie_hash_array[movie_hash_array.length - 1]}"
    if movie_hash_array.length > 0
        last_movie_language = movie_hash_array[movie_hash_array.length - 1]["original_language"]
    else 
        last_movie_language = "es"
    end
    
    #puts "movie hash array length: #{movie_hash_array[movie_hash_array.length - 1]}"
    puts "last movie language: #{last_movie_language}" 
    puts ""
    puts "current movie language: #{horror_movie_hash["original_language"]}"
    if movie_titles_array.include?(horror_movie_hash["original_title"]) == false && horror_movie_hash["original_language"] != last_movie_language
       movie_titles_array << horror_movie_hash["original_title"]
       movie_hash_array << horror_movie_hash
  
      overview = horror_movie_hash["overview"] == "" ? "overview" : horror_movie_hash["overview"]
      tagline = horror_movie_hash["tagline"] == "" ? "tagline" : horror_movie_hash["tagline"]
      genre = horror_movie_hash["genres"][0]["name"] == "" ? "no genre" : horror_movie_hash["genres"][0]["name"]
      backdrop_path = horror_movie_hash["backdrop_path"] == "" ? "backdrop" : horror_movie_hash["backdrop_path"]
      poster_path = horror_movie_hash["poster_path"] == "" ? "poster" : horror_movie_hash["poster_path"]
      backdrop_image_url = "https://image.tmdb.org/t/p/original/#{horror_movie_hash["backdrop_path"]}"
      poster_tmdb_url = "https://image.tmdb.org/t/p/w500/#{horror_movie_hash["poster_path"]}"
      movie_hash_for_csv = {
        poster_url: poster_tmdb_url,
        backdrop_image_url: backdrop_image_url,
        title: horror_movie_hash["original_title"],
        rating: horror_movie_hash["vote_average"],
        overview: overview,
        tagline: tagline,
        genre: genre,
        tmdb_key: horror_movie_hash["id"],
        runtime: horror_movie_hash["runtime"],
        release_date: horror_movie_hash["release_date"],
        language: horror_movie_hash["original_language"]
      }
      horror_movie_hash_index_and_titlesarray = [movie_hash_for_csv, horror_movie_hash, new_movie_index, movie_titles_array]
    else
      new_movie_index += 1
      puts "duplicate"
      get_unique_horror_movies(new_movie_index, movie_titles_array, movie_hash_array)
    end
  end
  
  
  def get_tmdb_movies(new_movie_index, horror_movies_n, movie_titles_array, movie_hash_array, n)
    movie_hash_for_csvarray = []  
    while horror_movies_n < n do
        horror_movie_hash_tmdbindex_and_titlesarray = get_unique_horror_movies(new_movie_index, movie_titles_array, movie_hash_array)
        horror_movie_hash = horror_movie_hash_tmdbindex_and_titlesarray[1]
        new_movie_index = horror_movie_hash_tmdbindex_and_titlesarray[2]
        movie_titles_array = horror_movie_hash_tmdbindex_and_titlesarray[3]
        puts "TMDB index: #{new_movie_index} Horror movie number: #{horror_movies_n}. Title: #{horror_movie_hash["original_title"]}  Instance:"
        movie_hash_for_csvarray << horror_movie_hash_tmdbindex_and_titlesarray[0]
        new_movie_index += 1
        horror_movies_n += 1
      end
      return movie_hash_for_csvarray
  end


def waiting_dots
    3.times do
        print '.'
        sleep(0.2)
    end
    puts ""
end


def generate_movies
    # get horror movies from TMDB api
    # tmdb has about 704,457 movies
    puts 'Seeding from TMDB'
    waiting_dots
    new_movie_index = 1
    horror_movies_n = 1
    movie_titles_array = []
    movie_hash_array = []
    movies_hash = get_tmdb_movies(new_movie_index, horror_movies_n, movie_titles_array, movie_hash_array, 100)
    #puts "hello"
    
    movies_hash.each do |movie|    
        #puts movie
        movie = Movie.create!(
            poster_url: movie[:poster_url],
            title: movie[:title],
            language: movie[:language],
            genre: movie[:genre],
            tmdb_key: movie[:tmdb_key]
        )
        puts "TMDB index: #{movie.tmdb_key}. Title: #{movie.title} Genre: #{movie.genre} Language: #{movie.language}"
    end
end



puts 'cleaning up database'
waiting_dots
Movie.destroy_all
puts 'database is clean'
puts 'Starting the seed'

generate_movies()