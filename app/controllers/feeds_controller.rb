class FeedsController < ApplicationController
  def show
    @feed = Feed.find(params[:id])
    @book = @feed.book_assignment.book
    @word_count = @feed.content.gsub(" ", "").length

    @meta_title = "#{@book.author_name}『#{@book.title}』(#{@feed.index}/#{@feed.book_assignment.count}"
    @breadcrumbs = [ {text: @book.title, link: book_assignment_path(@feed.book_assignment)}, {text: @feed.index} ]
    @no_index = true
  end
end
