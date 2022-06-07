class AddGenreToMovies < ActiveRecord::Migration[7.0]
  def change
    add_column :movies, :genre, :string
  end
end
