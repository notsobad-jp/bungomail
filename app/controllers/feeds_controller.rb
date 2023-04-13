class FeedsController < ApplicationController
  def show
    @feed = Feed.find(params[:id])
    @book = @feed.book_assignment.book
    @word_count = @feed.content.gsub(" ", "").length

    @meta_title = "#{@book.author_and_book_name}(#{@feed.index}/#{@feed.book_assignment.count}"
    @breadcrumbs = [ {text: @book.author_and_book_name, link: book_assignment_path(@feed.book_assignment)}, {text: @feed.index} ]
    @no_index = true
  end
end
