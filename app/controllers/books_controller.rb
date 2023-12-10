class BooksController < ApplicationController
  before_action :require_login, only: [:index]

  def index
    @keyword = params[:keyword]
    @category = params[:category]
    query = AozoraBook.where.not(words_count: 0).where(rights_reserved: false).where.not(category_id: nil).where(canonical_book_id: nil)
    query = query.where("REPLACE(author, ' ', '') LIKE ? OR REPLACE(title, ' ', '') LIKE ?", "%#{@keyword}%", "%#{@keyword}%") if @keyword
    query = query.where(category_id: @category) if @category && @category != 'all'
    @books = query.sorted.order(:words_count).page(params[:page]).per(50)

    @meta_title = "作品検索"
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
    @meta_noindex = true
    @breadcrumbs = [ {text: '作品検索', link: books_path}, {text: @meta_title} ]

    # ブンゴウサーチから来たユーザーが見れるように、未ログインでも警告付きで画面表示する
    flash[:warning] = "カスタム配信の利用には、有料プランのアカウントでログインする必要があります." if !current_user
  end
end
