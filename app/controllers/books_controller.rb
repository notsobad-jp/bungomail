class BooksController < ApplicationController
  before_action :require_login, only: [:index]

  def index
    @keyword = params[:keyword].presence
    @category = params[:category]&.to_sym
    @page = params[:page] ? params[:page].to_i : 1

    res = Book.where(keyword: @keyword, category: @category, page: @page)
    @books, @has_next, @total_count = res.values_at("books", "hasNext", "totalCount")

    @meta_title = "作品検索"
    @meta_noindex = true
  end

  def show
    @book = AozoraBook.find(params[:id])
    @campaign = Campaign.new(
      book_id: params[:id],
      book_type: 'AozoraBook',
      start_date: params[:start_date],
      end_date: params[:end_date],
      delivery_time: params[:delivery_time] || '07:00',
    )

    @meta_title = @book.title
    @meta_noindex = true
    @breadcrumbs = [ {text: '作品検索', link: books_path}, {text: @meta_title} ]
  end
end
