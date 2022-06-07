class AddTmdbKeyToMovies < ActiveRecord::Migration[7.0]
  def change
    add_column :movies, :tmdb_key, :integer
  end
end
