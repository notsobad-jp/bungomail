class BooksController < ApplicationController
  before_action :set_author_and_category, only: [:index]

  def index
    books = @category[:id] == 'all' ? AozoraBook.where.not(category_id: nil) : AozoraBook.where(category_id: @category[:id])
    books = @author[:id] == 'all' ? books.where.not(author_id: nil) : books.where(author_id: @author[:id])
    @books = books.where.not(words_count: 0).where(canonical_book_id: nil).sorted.order(:words_count).page(params[:page]).per(50)

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

  private

  def set_author_and_category
    @categories = AozoraBook::CATEGORIES
    @category = @categories[params[:category_id]&.to_sym] || @categories[:all]

    @author = if ( params[:author_id] && book = AozoraBook.find_by(author_id: params[:author_id]))
      { id: book.author_id, name: book.author_name }
    else
      { id: 'all', name: t(:all_authors, scope: [:search, :controllers, :application]) }
    end
    @authors = AozoraBook.popular_authors
  end
end
