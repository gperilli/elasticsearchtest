class Movie < ApplicationRecord
    searchkick word_middle: [:title, :genre]

    def search_data
        {
            title: title,
            genre: genre
        }
    end
end
