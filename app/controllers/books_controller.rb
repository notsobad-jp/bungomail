class BooksController < ApplicationController
  def index
    @books = AozoraBook.where.not(words_count: 0).where(rights_reserved: false).where.not(category_id: nil).where(canonical_book_id: nil).sorted.order(:words_count).page(params[:page]).per(50)
    @meta_title = "配信する作品を探す"
    @meta_noindex = true
  end

  def show
    @book = AozoraBook.find(params[:id])
    @book_assignment = BookAssignment.new(
      book_id: params[:id],
      book_type: 'AozoraBook',
      start_date: params[:start_date],
      end_date: params[:end_date],
      delivery_time: params[:delivery_time] || '07:00',
    )

    @meta_title = @book.title
    @breadcrumbs = [ {text: 'カスタム配信', link: page_path(:custom_delivery)}, {text: @meta_title} ]

    flash[:warning] = "カスタム配信の利用には、有料プランのアカウントでログインする必要があります." if !current_user
  end
end
