class FeedsController < ApplicationController
  def show
    @feed = Feed.find(params[:id])
    @book = @feed.distribution.book
    @word_count = @feed.content.gsub(" ", "").length

    @meta_title = "#{@book.author_and_book_name}(#{@feed.index}/#{@feed.distribution.count}"
    @breadcrumbs = [ {text: @book.author_and_book_name, link: distribution_path(@feed.distribution)}, {text: @feed.index} ]
    @no_index = true
  end
end
