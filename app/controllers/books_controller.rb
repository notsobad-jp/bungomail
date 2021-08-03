class BooksController < ApplicationController
  def show
    @book = AozoraBook.find(params[:id])
    @book_assignment = BookAssignment.new(
      book_id: params[:id],
      book_type: 'AozoraBook',
      start_date: params[:start_date],
      end_date: params[:end_date],
    )

    @meta_title = @book.title
    @breadcrumbs = [ {text: 'カスタム配信'}, {text: @meta_title} ]
  end
end
