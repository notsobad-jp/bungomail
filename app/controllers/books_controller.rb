class BooksController < ApplicationController
  def show
    @book = AozoraBook.find(params[:id])
    @book_assignment = BookAssignment.new(book_id: params[:id], book_type: 'AozoraBook')

    @meta_title = @book.title
    @breadcrumbs = [ {text: @meta_title} ]
  end
end
